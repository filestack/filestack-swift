//
//  MultipartUpload.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/18/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/// :nodoc:
enum MultipartUploadError: Error {
    case invalidFile
    case aborted
    case custom(description: String)
}

extension MultipartUploadError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidFile:
            return "The file provided is invalid or could not be found"
        case .aborted:
            return "The upload operation was aborted."
        case let .custom(description):
            return description
        }
    }
}

/// Chunksize depending on upload type.
enum ChunkSize: Int {
    /// Regular (5 megabytes)
    case regular = 5_242_880
    /// Intelligent Ingestion (8 megabytes)
    case ii = 8_388_608
}

/// This class allows uploading a single `Uploadable` item to a given storage location.
class MultipartUpload: Uploader {
    // MARK: - Internal Properties

    let uuid = UUID()
    let masterProgress = MirroredProgress()
    var uploadProgress: ((Progress) -> Void)?
    var completionHandler: ((NetworkJSONResponse) -> Void)?

    // MARK: - Private Properties

    private var uploadable: Uploadable
    private var masterProgressFractionCompletedObserver: NSKeyValueObservation?

    private let queue: DispatchQueue
    private let apiKey: String
    private let options: UploadOptions
    private let security: Security?
    private let uploadQueue: DispatchQueue = DispatchQueue(label: "com.filestack.upload-queue")
    private let maxRetries = 5

    private let masterOperationUnderlyingQueue = DispatchQueue(label: "com.filestack.master-upload-operation-queue",
                                                               qos: .utility)

    private let partOperationUnderlyingQueue = DispatchQueue(label: "com.filestack.part-upload-operation-queue",
                                                             qos: .utility,
                                                             attributes: .concurrent)

    private let masterOperationQueue = OperationQueue()
    private let partOperationQueue = OperationQueue()

    // MARK: - Lifecycle

    init(using uploadable: Uploadable,
         options: UploadOptions,
         queue: DispatchQueue = .main,
         apiKey: String,
         security: Security? = nil) {
        self.uploadable = uploadable
        self.queue = queue
        self.apiKey = apiKey
        self.options = options
        self.security = security
        self.masterProgress.totalUnitCount = Int64(uploadable.size ?? 0)

        masterProgressFractionCompletedObserver = masterProgress.observe(\.fractionCompleted, options: [.new]) { _, _ in
            queue.async {
                self.uploadProgress?(self.progress)
            }
        }

        masterOperationQueue.underlyingQueue = masterOperationUnderlyingQueue
        masterOperationQueue.maxConcurrentOperationCount = 1
        partOperationQueue.underlyingQueue = partOperationUnderlyingQueue
        partOperationQueue.maxConcurrentOperationCount = options.partUploadConcurrency
    }

    // MARK: - Uploadable Protocol Implementation

    private(set) var currentStatus: UploadStatus = .notStarted {
        didSet {
            switch currentStatus {
            case .cancelled:
                progress.cancel()
            default:
                break
            }
        }
    }

    lazy var progress = {
        masterProgress.mirror
    }()

    @discardableResult func cancel() -> Bool {
        guard currentStatus != .cancelled else { return false }

        uploadQueue.sync {
            partOperationQueue.cancelAllOperations()
            masterOperationQueue.cancelAllOperations()
            currentStatus = .cancelled
        }

        queue.async {
            self.completionHandler?(NetworkJSONResponse(with: MultipartUploadError.aborted))
            self.completionHandler = nil
        }

        return true
    }

    @discardableResult func start() -> Bool {
        switch currentStatus {
        case .notStarted:
            uploadQueue.async {
                self.doUploadFile()
            }

            return true
        default:
            return false
        }
    }

    func uploadFiles() {
        start()
    }
}

// MARK: - Private Functions

private extension MultipartUpload {
    func fail(with error: Error) {
        self.currentStatus = .failed

        queue.async {
            self.completionHandler?(NetworkJSONResponse(with: error))
        }
    }

    func doUploadFile() {
        currentStatus = .inProgress

        guard let descriptor = setupUploadDescriptor() else { return }

        var part: Int = 0
        var bytesLeft: UInt64 = descriptor.filesize
        var partsAndEtags: [Int: String] = [:]
        let chunkSize = (descriptor.useIntelligentIngestion ? ChunkSize.ii : ChunkSize.regular).rawValue

        var failMessage: String?

        // Submit all parts
        while currentStatus == .inProgress, bytesLeft > 0 {
            part += 1

            let partSize = Int(min(UInt64(chunkSize), bytesLeft))
            let offset = (descriptor.filesize - bytesLeft)
            let partOperation: MultipartUploadSubmitPartOperation

            if descriptor.useIntelligentIngestion {
                partOperation = MultipartIntelligentUploadSubmitPartOperation(offset: offset,
                                                                              part: part,
                                                                              partSize: partSize,
                                                                              descriptor: descriptor)
            } else {
                partOperation = MultipartRegularUploadSubmitPartOperation(offset: offset,
                                                                          part: part,
                                                                          partSize: partSize,
                                                                          descriptor: descriptor)
            }

            masterProgress.addChild(partOperation.progress, withPendingUnitCount: Int64(partSize))

            weak var weakPartOperation = partOperation

            let checkpointOperation = BlockOperation {
                guard let partOperation = weakPartOperation else { return }

                if partOperation.didFail {
                    failMessage = "Part operation did fail."
                }

                if !descriptor.useIntelligentIngestion {
                    if let responseEtag = partOperation.responseEtag {
                        partsAndEtags[partOperation.part] = responseEtag
                    } else {
                        failMessage = "Part operation was expected to provide response ETags."
                    }
                }

                if self.currentStatus != .inProgress {
                    self.partOperationQueue.cancelAllOperations()
                }
            }

            checkpointOperation.addDependency(partOperation)
            partOperationQueue.addOperation(partOperation)
            partOperationQueue.addOperation(checkpointOperation)

            bytesLeft -= UInt64(partSize)
        }

        masterOperationQueue.addOperation {
            self.partOperationQueue.waitUntilAllOperationsAreFinished()

            if let failMessage = failMessage {
                let error = MultipartUploadError.custom(description: failMessage)
                self.fail(with: error)
            } else {
                self.addCompleteOperation(partsAndEtags: partsAndEtags,
                                          descriptor: descriptor,
                                          retriesLeft: self.maxRetries)
            }
        }
    }

    // Calls `multipart/start`, and, assuming uploadable is valid and the request succeeds,
    // returns a `MultipartUploadDescriptor`.
    func setupUploadDescriptor() -> UploadDescriptor? {
        let filename = options.storeOptions.filename ?? uploadable.filename ?? UUID().uuidString
        let mimeType = options.storeOptions.mimeType ?? uploadable.mimeType ?? "text/plain"

        guard let filesize = uploadable.size, !filename.isEmpty else {
            fail(with: MultipartUploadError.invalidFile)
            return nil
        }

        let startOperation = MultipartUploadStartOperation(apiKey: apiKey,
                                                           fileName: filename,
                                                           fileSize: filesize,
                                                           mimeType: mimeType,
                                                           storeOptions: options.storeOptions,
                                                           security: security,
                                                           multipart: options.preferIntelligentIngestion)

        guard currentStatus == .inProgress else { return nil }

        masterOperationQueue.addOperation(startOperation)
        masterOperationQueue.waitUntilAllOperationsAreFinished()

        // Ensure that there's a response and JSON payload or fail.
        guard let json = startOperation.response?.json else {
            let error = MultipartUploadError.custom(description: "Unable to obtain JSON from /multipart/start response.")
            fail(with: error)
            return nil
        }

        // Did the REST API return an error? Fail and send the error downstream.
        if let apiErrorDescription = json["error"] as? String {
            fail(with: MultipartUploadError.custom(description: "API Error: \(apiErrorDescription)"))
            return nil
        }

        // Ensure that there's an uri, region, and upload_id in the JSON payload or fail.
        guard let uri = json["uri"] as? String,
              let region = json["region"] as? String,
              let uploadID = json["upload_id"] as? String else {
            let error = MultipartUploadError.custom(description: "JSON payload is missing required parameters.")
            fail(with: error)
            return nil
        }

        // Detect whether intelligent ingestion is available.
        // The JSON payload should contain an "upload_type" field with value "intelligent_ingestion".
        let canUseIntelligentIngestion: Bool

        if let uploadType = json["upload_type"] as? String, uploadType == "intelligent_ingestion" {
            canUseIntelligentIngestion = true
        } else {
            canUseIntelligentIngestion = false
        }

        guard let reader = uploadable.reader else {
            let error = MultipartUploadError.custom(description: "Unable to instantiate uploadable data reader.")
            fail(with: error)
            return nil
        }

        let descriptor = UploadDescriptor(
            apiKey: apiKey,
            security: security,
            options: options,
            reader: reader,
            filename: filename,
            filesize: filesize,
            mimeType: mimeType,
            uri: uri,
            region: region,
            uploadID: uploadID,
            useIntelligentIngestion: canUseIntelligentIngestion
        )

        return descriptor
    }

    func addCompleteOperation(partsAndEtags: [Int: String],
                              descriptor: UploadDescriptor,
                              retriesLeft: Int) {
        let completeOperation = MultipartUploadCompleteOperation(partsAndEtags: partsAndEtags, descriptor: descriptor)

        weak var weakCompleteOperation = completeOperation

        let checkpointOperation = BlockOperation {
            guard let completeOperation = weakCompleteOperation else { return }
            let jsonResponse = completeOperation.response
            let isNetworkError = jsonResponse.response == nil && jsonResponse.error != nil

            // Check for any error response
            if jsonResponse.response?.statusCode != 200 || isNetworkError {
                if retriesLeft > 0 {
                    let delay = isNetworkError ? 0 : pow(2, Double(self.maxRetries - retriesLeft))

                    // Retry in `delay` seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        self.addCompleteOperation(partsAndEtags: partsAndEtags,
                                                  descriptor: descriptor,
                                                  retriesLeft: retriesLeft - 1)
                    }
                } else {
                    let error = MultipartUploadError.custom(
                        description: "Unable to submit complete operation after \(self.maxRetries)."
                    )

                    self.fail(with: error)
                    return
                }
            } else {
                // Return response to the user.
                self.queue.async {
                    self.currentStatus = .completed
                    self.completionHandler?(jsonResponse)
                }
            }
        }

        checkpointOperation.addDependency(completeOperation)
        masterOperationQueue.addOperation(completeOperation)
        masterOperationQueue.addOperation(checkpointOperation)
    }
}

// MARK: - CustomStringConvertible Conformance  Conformance

extension MultipartUpload {
    /// :nodoc:
    public var description: String {
        return Tools.describe(subject: self, only: ["currentStatus", "progress"])
    }
}
