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
    case failedChunkUploads
    case aborted
}


@objc(FSMultipartUpload) public class MultipartUpload: NSObject {

    // MARK: - Properties

    let regularChunkSize = 5 * Int(pow(Double(1024), Double(2)))
    let resumableChunkSize = 8 * Int(pow(Double(1024), Double(2)))
    let maxRetries = 5

    // MARK: - Private Properties

    private var progress: Progress
    private var shouldAbort: Bool
    private var useIntelligentIngestionIfAvailable: Bool

    private let localURL: URL
    private let queue: DispatchQueue
    private let uploadProgress: ((Progress) -> Void)?
    private let completionHandler: (NetworkJSONResponse?) -> Void
    private let apiKey: String
    private let storage: StorageLocation
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

    internal init(at localURL: URL,
                  queue: DispatchQueue = .main,
                  uploadProgress: ((Progress) -> Void)? = nil,
                  completionHandler: @escaping (NetworkJSONResponse?) -> Void,
                  partUploadConcurrency: Int = 5,
                  chunkUploadConcurrency: Int = 8,
                  apiKey: String,
                  storage: StorageLocation,
                  security: Security? = nil,
                  useIntelligentIngestionIfAvailable: Bool = true) {

        self.localURL = localURL
        self.queue = queue
        self.uploadProgress = uploadProgress
        self.completionHandler = completionHandler
        self.apiKey = apiKey
        self.storage = storage
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
    public func cancel() {

        uploadQueue.sync {
            shouldAbort = true
            uploadOperationQueue.cancelAllOperations()
        }

        fail(with: MultipartUploadError.aborted)
    }


    // MARK: - Internal Functions

    internal func uploadFile() {

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

        if let uploadProgress = uploadProgress {
            queue.async {
                uploadProgress(self.progress)
            }
        }
    }

    private func doUploadFile() {

        let fileName = localURL.lastPathComponent
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
                                                           storeLocation: storage,
                                                           security: security,
                                                           useIntelligentIngestionIfAvailable: useIntelligentIngestionIfAvailable)

        if shouldAbort {
            fail(with: MultipartUploadError.aborted)
            return
        } else {
            uploadOperationQueue.addOperation(startOperation)
        }

        uploadOperationQueue.waitUntilAllOperationsAreFinished()

        // Check for start response

        guard let response = startOperation.response,
            let json = response.json,
            let uri = json["uri"] as? String,
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
                                                                   storageLocation: storage,
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
                                                                 storeLocation: storage,
                                                                 partsAndEtags: partsAndEtags,
                                                                 useIntelligentIngestion: useIntelligentIngestion)

        weak var weakCompleteOperation = completeOperation

        let checkpointOperation = BlockOperation {
            guard let completeOperation = weakCompleteOperation else { return }

            let jsonResponse = completeOperation.response
            let isNetworkError = jsonResponse?.response == nil && jsonResponse?.error != nil

            // Check for any error response
            if jsonResponse?.response?.statusCode != 200 || isNetworkError {
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
