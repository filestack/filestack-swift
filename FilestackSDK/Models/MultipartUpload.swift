//
//  MultipartUpload.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/18/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

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

        case .error(let description):

            return description

        }
    }
}


/// :nodoc:
@objc(FSMultipartUpload) public class MultipartUpload: NSObject {

    // MARK: - Public Properties

    public var localURL: URL?

    // MARK: - Internal Properties

    let regularChunkSize = 5 * Int(pow(Double(1024), Double(2)))
    let resumableChunkSize = 8 * Int(pow(Double(1024), Double(2)))
    let maxRetries = 5

    // MARK: - Private Properties

    private var progress: Progress
    private var shouldAbort: Bool
    private var useIntelligentIngestionIfAvailable: Bool

    private let queue: DispatchQueue
    private let uploadProgress: ((Progress) -> Void)?
    private let completionHandler: (NetworkJSONResponse) -> Void
    private let apiKey: String
    private let storeOptions: StorageOptions
    private let security: Security?
    private let uploadQueue: DispatchQueue = DispatchQueue(label: "com.filestack.upload-queue")

    private let uploadOperationQueue: OperationQueue = {
        $0.underlyingQueue = DispatchQueue(label: "com.filestack.upload-operation-queue",
                                           qos: .utility,
                                           attributes: .concurrent)
        return $0
    }(OperationQueue())

    private let chunkUploadConcurrency: Int


    // MARK: - Lifecyle Functions

    internal init(at localURL: URL? = nil,
                  queue: DispatchQueue = .main,
                  uploadProgress: ((Progress) -> Void)? = nil,
                  completionHandler: @escaping (NetworkJSONResponse) -> Void,
                  partUploadConcurrency: Int = 5,
                  chunkUploadConcurrency: Int = 8,
                  apiKey: String,
                  storeOptions: StorageOptions,
                  security: Security? = nil,
                  useIntelligentIngestionIfAvailable: Bool = true) {
        if let localURL = localURL {
            self.localURL = localURL
        }
        self.queue = queue
        self.uploadProgress = uploadProgress
        self.completionHandler = completionHandler
        self.apiKey = apiKey
        self.storeOptions = storeOptions
        self.security = security
        self.shouldAbort = false
        self.progress = Progress(totalUnitCount: 0)
        self.useIntelligentIngestionIfAvailable = useIntelligentIngestionIfAvailable
        self.uploadOperationQueue.maxConcurrentOperationCount = partUploadConcurrency
        self.chunkUploadConcurrency = chunkUploadConcurrency
    }

    // MARK: - Public Functions

    /**
        Cancels a multipart upload request.
     */
    @objc public func cancel() {
        uploadQueue.sync {
            shouldAbort = true
            uploadOperationQueue.cancelAllOperations()
        }
        fail(with: MultipartUploadError.aborted)
    }

    public func uploadFile() {
        uploadQueue.async {
            self.doUploadFile()
        }
    }

    // MARK: - Private Functions

    private func fail(with error: Error) {
        let errorResponse = NetworkJSONResponse(with: error)
        queue.async {
            self.completionHandler(errorResponse)
        }
    }

    private func updateProgress(uploadedBytes: Int64) {
        progress.completedUnitCount = uploadedBytes
        queue.async {
            self.uploadProgress?(self.progress)
        }
    }

    private func doUploadFile() {
        guard let localURL = localURL else { return }
        let fileName = storeOptions.filename ?? localURL.lastPathComponent
        let mimeType = localURL.mimeType() ?? "text/plain"
        var shouldUseIntelligentIngestion = false

        guard !fileName.isEmpty, let fileSize = localURL.size() else {
            fail(with: MultipartUploadError.invalidFile)
            return
        }

        progress = Progress(totalUnitCount: Int64(fileSize))

        let startOperation = MultipartUploadStartOperation(apiKey: apiKey,
                                                           fileName: fileName,
                                                           fileSize: fileSize,
                                                           mimeType: mimeType,
                                                           storeOptions: storeOptions,
                                                           security: security,
                                                           useIntelligentIngestionIfAvailable: useIntelligentIngestionIfAvailable)

        if shouldAbort {
            fail(with: MultipartUploadError.aborted)
            return
        } else {
            uploadOperationQueue.addOperation(startOperation)
        }

        uploadOperationQueue.waitUntilAllOperationsAreFinished()

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
        if let uploadType = json["upload_type"] as? String, uploadType == "intelligent_ingestion" {
            shouldUseIntelligentIngestion = true
        }

        var part: Int = 0
        var chunkSize: Int
        var seekPoint: UInt64 = 0

        if shouldUseIntelligentIngestion {
            chunkSize = resumableChunkSize
        } else {
            chunkSize = regularChunkSize
        }

        var partsAndEtags: [Int: String] = [:]
        var totalUploadedBytes: Int64 = 0

        let beforeCompleteCheckPointOperation = BlockOperation()

        beforeCompleteCheckPointOperation.completionBlock = {
            if self.shouldAbort {
                self.fail(with: MultipartUploadError.aborted)
                return
            } else {
                self.addCompleteOperation(fileName: fileName,
                                          fileSize: fileSize,
                                          mimeType: mimeType,
                                          uri: uri,
                                          region: region,
                                          uploadID: uploadID,
                                          partsAndEtags: partsAndEtags,
                                          useIntelligentIngestion: shouldUseIntelligentIngestion,
                                          retriesLeft: self.maxRetries)
            }
        }

        // Submit all parts
        while !shouldAbort && seekPoint < fileSize {
            part += 1

            let partOperation = MultipartUploadSubmitPartOperation(seek: seekPoint,
                                                                   localURL: localURL,
                                                                   fileName: fileName,
                                                                   fileSize: fileSize,
                                                                   apiKey: apiKey,
                                                                   part: part,
                                                                   uri: uri,
                                                                   region: region,
                                                                   uploadID: uploadID,
                                                                   storeOptions: storeOptions,
                                                                   chunkSize: chunkSize,
                                                                   chunkUploadConcurrency: chunkUploadConcurrency,
                                                                   useIntelligentIngestion: shouldUseIntelligentIngestion) { uploadedBytes in

                totalUploadedBytes += uploadedBytes
                self.updateProgress(uploadedBytes: totalUploadedBytes)
            }

            weak var weakPartOperation = partOperation

            let checkpointOperation = BlockOperation {
                guard let partOperation = weakPartOperation else { return }

                if partOperation.didFail {
                    self.shouldAbort = true
                }

                if !shouldUseIntelligentIngestion {
                    if let responseEtag = partOperation.responseEtag {
                        partsAndEtags[partOperation.part] = responseEtag
                    } else {
                        self.shouldAbort = true
                    }
                }

                if self.shouldAbort {
                    self.uploadOperationQueue.cancelAllOperations()
                }
            }

            checkpointOperation.addDependency(partOperation)
            uploadOperationQueue.addOperation(partOperation)
            uploadOperationQueue.addOperation(checkpointOperation)

            beforeCompleteCheckPointOperation.addDependency(partOperation)
            beforeCompleteCheckPointOperation.addDependency(checkpointOperation)

            seekPoint += UInt64(chunkSize)
        }

        uploadOperationQueue.addOperation(beforeCompleteCheckPointOperation)
    }

    private func addCompleteOperation(fileName: String,
                                      fileSize: UInt64,
                                      mimeType: String,
                                      uri: String,
                                      region: String,
                                      uploadID: String,
                                      partsAndEtags: [Int : String],
                                      useIntelligentIngestion: Bool,
                                      retriesLeft: Int) {

        let completeOperation = MultipartUploadCompleteOperation(apiKey: apiKey,
                                                                 fileName: fileName,
                                                                 fileSize: fileSize,
                                                                 mimeType: mimeType,
                                                                 uri: uri,
                                                                 region: region,
                                                                 uploadID: uploadID,
                                                                 storeOptions: storeOptions,
                                                                 partsAndEtags: partsAndEtags,
                                                                 useIntelligentIngestion: useIntelligentIngestion)

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
                                                  useIntelligentIngestion: useIntelligentIngestion,
                                                  retriesLeft: retriesLeft - 1)
                    }
                } else {
                    self.fail(with: MultipartUploadError.aborted)
                    return
                }
            } else {
                // Return response to the user.
                self.queue.async {
                    self.completionHandler(jsonResponse)
                }
            }
        }

        checkpointOperation.addDependency(completeOperation)
        uploadOperationQueue.addOperation(completeOperation)
        uploadOperationQueue.addOperation(checkpointOperation)
    }
}
