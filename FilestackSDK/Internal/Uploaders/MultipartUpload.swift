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
    case error(description: String)
}

extension MultipartUploadError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidFile:
            return "The file provided is invalid or could not be found"
        case .aborted:
            return "The upload operation was aborted"
        case let .error(description):
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
    typealias UploadProgress = (Int64) -> Void

    // MARK: - Internal Properties

    internal let masterProgress = MirroredProgress()
    internal var uploadProgress: ((Progress) -> Void)?
    internal var completionHandler: ((NetworkJSONResponse) -> Void)?

    // MARK: - Private Properties

    private var uploadable: Uploadable
    private var shouldAbort: Bool

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

    // MARK: - Lifecycle Functions

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
        self.shouldAbort = false
        self.masterProgress.totalUnitCount = Int64(uploadable.size ?? 0)

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
            shouldAbort = true
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

private extension MultipartUpload {
    func fail(with error: Error) {
        self.currentStatus = .failed

        queue.async {
            self.completionHandler?(NetworkJSONResponse(with: error))
        }
    }

    func doUploadFile() {
        currentStatus = .inProgress

        let fileName = options.storeOptions.filename ?? uploadable.filename ?? UUID().uuidString
        let mimeType = options.storeOptions.mimeType ?? uploadable.mimeType ?? "text/plain"

        guard let fileSize = uploadable.size, !fileName.isEmpty else {
            fail(with: MultipartUploadError.invalidFile)
            return
        }

        let startOperation = MultipartUploadStartOperation(apiKey: apiKey,
                                                           fileName: fileName,
                                                           fileSize: fileSize,
                                                           mimeType: mimeType,
                                                           storeOptions: options.storeOptions,
                                                           security: security,
                                                           useIntelligentIngestionIfAvailable: options.preferIntelligentIngestion)

        if shouldAbort {
            fail(with: MultipartUploadError.aborted)
            return
        } else {
            masterOperationQueue.addOperation(startOperation)
        }

        masterOperationQueue.waitUntilAllOperationsAreFinished()

        // Ensure that there's a response and JSON payload or fail.
        guard let response = startOperation.response, let json = response.json else {
            fail(with: MultipartUploadError.aborted)
            return
        }

        // Did the REST API return an error? Fail and send the error downstream.
        if let apiErrorDescription = json["error"] as? String {
            fail(with: MultipartUploadError.error(description: apiErrorDescription))
            return
        }

        // Ensure that there's an uri, region, and upload_id in the JSON payload or fail.
        guard let uri = json["uri"] as? String,
            let region = json["region"] as? String,
            let uploadID = json["upload_id"] as? String else {
            fail(with: MultipartUploadError.aborted)
            return
        }

        // Detect whether intelligent ingestion is available.
        // The JSON payload should contain an "upload_type" field with value "intelligent_ingestion".
        let canUseIntelligentIngestion: Bool!

        if let uploadType = json["upload_type"] as? String, uploadType == "intelligent_ingestion" {
            canUseIntelligentIngestion = true
        } else {
            canUseIntelligentIngestion = false
        }

        var part: Int = 0
        var seekPoint: UInt64 = 0
        var partsAndEtags: [Int: String] = [:]

        let chunkSize = (canUseIntelligentIngestion ? ChunkSize.ii : ChunkSize.regular).rawValue

        // Submit all parts
        while !shouldAbort, seekPoint < fileSize {
            part += 1

            guard let reader = uploadable.reader else {
                self.shouldAbort = true
                continue
            }

            let partOperation = uploadSubmitPartOperation(usingIntelligentIngestion: canUseIntelligentIngestion,
                                                          seek: seekPoint,
                                                          reader: reader,
                                                          fileName: fileName,
                                                          fileSize: fileSize,
                                                          part: part,
                                                          uri: uri,
                                                          region: region,
                                                          uploadId: uploadID,
                                                          chunkSize: chunkSize)

            weak var weakPartOperation = partOperation

            let checkpointOperation = BlockOperation {
                guard let partOperation = weakPartOperation else { return }

                if partOperation.didFail {
                    self.shouldAbort = true
                }

                if !canUseIntelligentIngestion {
                    if let responseEtag = partOperation.responseEtag {
                        partsAndEtags[partOperation.part] = responseEtag
                    } else {
                        self.shouldAbort = true
                    }
                }

                if self.shouldAbort {
                    self.partOperationQueue.cancelAllOperations()
                }
            }

            checkpointOperation.addDependency(partOperation)
            partOperationQueue.addOperation(partOperation)
            partOperationQueue.addOperation(checkpointOperation)

            seekPoint += UInt64(chunkSize)
        }

        masterOperationQueue.addOperation {
            self.partOperationQueue.waitUntilAllOperationsAreFinished()

            if self.shouldAbort {
                self.fail(with: MultipartUploadError.aborted)
            } else {
                self.addCompleteOperation(fileName: fileName,
                                          fileSize: fileSize,
                                          mimeType: mimeType,
                                          uri: uri,
                                          region: region,
                                          uploadID: uploadID,
                                          partsAndEtags: partsAndEtags,
                                          usingIntelligentIngestion: canUseIntelligentIngestion,
                                          retriesLeft: self.maxRetries)
            }
        }
    }

    func uploadSubmitPartOperation(usingIntelligentIngestion: Bool,
                                   seek: UInt64,
                                   reader: UploadableReader,
                                   fileName: String,
                                   fileSize: UInt64,
                                   part: Int,
                                   uri: String,
                                   region: String,
                                   uploadId: String,
                                   chunkSize: Int) -> MultipartUploadSubmitPartOperation {
        if usingIntelligentIngestion {
            return MultipartIntelligentUploadSubmitPartOperation(seek: seek,
                                                                 reader: reader,
                                                                 fileName: fileName,
                                                                 fileSize: fileSize,
                                                                 apiKey: apiKey,
                                                                 part: part,
                                                                 uri: uri,
                                                                 region: region,
                                                                 uploadID: uploadId,
                                                                 storeOptions: options.storeOptions,
                                                                 chunkSize: chunkSize,
                                                                 chunkUploadConcurrency: options.chunkUploadConcurrency,
                                                                 uploadProgress: updateProgress)
        } else {
            return MultipartRegularUploadSubmitPartOperation(seek: seek,
                                                             reader: reader,
                                                             fileName: fileName,
                                                             fileSize: fileSize,
                                                             apiKey: apiKey,
                                                             part: part,
                                                             uri: uri,
                                                             region: region,
                                                             uploadID: uploadId,
                                                             storeOptions: options.storeOptions,
                                                             chunkSize: chunkSize,
                                                             uploadProgress: updateProgress)
        }
    }

    func updateProgress(progress: Int64) {
        masterProgress.completedUnitCount += progress

        queue.async {
            self.uploadProgress?(self.progress)
        }
    }

    func addCompleteOperation(fileName: String,
                              fileSize: UInt64,
                              mimeType: String,
                              uri: String,
                              region: String,
                              uploadID: String,
                              partsAndEtags: [Int: String],
                              usingIntelligentIngestion: Bool,
                              retriesLeft: Int) {
        let completeOperation = MultipartUploadCompleteOperation(apiKey: apiKey,
                                                                 fileName: fileName,
                                                                 fileSize: fileSize,
                                                                 mimeType: mimeType,
                                                                 uri: uri,
                                                                 region: region,
                                                                 uploadID: uploadID,
                                                                 storeOptions: options.storeOptions,
                                                                 partsAndEtags: partsAndEtags,
                                                                 security: security,
                                                                 preferIntelligentIngestion: usingIntelligentIngestion)

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
                        self.addCompleteOperation(fileName: fileName,
                                                  fileSize: fileSize,
                                                  mimeType: mimeType,
                                                  uri: uri,
                                                  region: region,
                                                  uploadID: uploadID,
                                                  partsAndEtags: partsAndEtags,
                                                  usingIntelligentIngestion: usingIntelligentIngestion,
                                                  retriesLeft: retriesLeft - 1)
                    }
                } else {
                    self.fail(with: MultipartUploadError.aborted)
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

// MARK: - CustomStringConvertible

extension MultipartUpload {
    /// :nodoc:
    public var description: String {
        return Tools.describe(subject: self, only: ["currentStatus", "progress"])
    }
}
