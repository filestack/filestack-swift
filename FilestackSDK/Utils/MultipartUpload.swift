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
    case invalidResponse
    case failedChunkUploads
}


internal class MultipartUpload {


    // MARK: - Properties

    internal let apiKey: String
    internal let storage: StorageLocation
    internal let security: Security?

    // MARK: - Private Properties

    private let uploadOperationQueue: OperationQueue = {

        $0.underlyingQueue = DispatchQueue(label: "com.filestack.upload-operation-queue",
                                           qos: .utility,
                                           attributes: .concurrent)

        $0.maxConcurrentOperationCount = 5 // concurrent

        return $0
    }(OperationQueue())


    // MARK: - Lifecyle Functions

    internal init(apiKey: String, storage: StorageLocation, security: Security? = nil) {

        self.apiKey = apiKey
        self.storage = storage
        self.security = security
    }


    // MARK: - Internal Functions

    internal func uploadFile(at localURL: URL,
                             queue: DispatchQueue = .main,
                             completionHandler: @escaping (NetworkJSONResponse?) -> Void) {

        let fileName = localURL.lastPathComponent
        let mimeType = localURL.mimeType() ?? "text/plain"

        guard !fileName.isEmpty, let fileSize = localURL.size() else {
            let errorResponse = NetworkJSONResponse(with: MultipartUploadError.invalidFile)

            queue.async {
                completionHandler(errorResponse)
            }

            return
        }

        let startOperation = MultipartUploadStartOperation(apiKey: apiKey,
                                                           fileName: fileName,
                                                           fileSize: fileSize,
                                                           mimeType: mimeType,
                                                           storeLocation: storage,
                                                           security: security)

        startOperation.completionBlock = {

            guard let response = startOperation.response,
                  let json = response.json,
                  let uri = json["uri"] as? String,
                  let region = json["region"] as? String,
                  let uploadID = json["upload_id"] as? String else {

                let errorResponse = NetworkJSONResponse(with: MultipartUploadError.invalidResponse)

                queue.async {
                    completionHandler(errorResponse)
                }

                return
            }

            var seekPoint: UInt64 = 0
            var part: Int = 1
            var partOperations: [MultipartUploadSubmitPartOperation] = []

            while seekPoint < fileSize {
                let partOperation = MultipartUploadSubmitPartOperation(seek: seekPoint,
                                                                       localURL: localURL,
                                                                       fileName: fileName,
                                                                       apiKey: self.apiKey,
                                                                       part: part,
                                                                       uri: uri,
                                                                       region: region,
                                                                       uploadID: uploadID,
                                                                       storageLocation: self.storage)

                self.uploadOperationQueue.addOperation(partOperation)

                seekPoint += UInt64(Config.defaultChunkSize)
                part += 1

                partOperations.append(partOperation)
            }

            let blockOperation = BlockOperation()

            for operation in partOperations {
                blockOperation.addDependency(operation)
            }

            blockOperation.addExecutionBlock {
                var partsAndEtags: [Int: String] = [:]
                var missingEtags = false

                for operation in partOperations {
                    guard let responseETag = operation.responseEtag else {
                        missingEtags = true
                        break
                    }

                    partsAndEtags[operation.part] = responseETag
                }

                print("partsAndEtags = \(partsAndEtags), missingEtags = \(missingEtags)")

                if missingEtags {
                    let errorResponse = NetworkJSONResponse(with: MultipartUploadError.failedChunkUploads)

                    queue.async {
                        completionHandler(errorResponse)
                    }

                    return
                }

                let completeOperation = MultipartUploadCompleteOperation(apiKey: self.apiKey,
                                                                         fileName: fileName,
                                                                         fileSize: fileSize,
                                                                         mimeType: mimeType,
                                                                         uri: uri,
                                                                         region: region,
                                                                         uploadID: uploadID,
                                                                         storeLocation: self.storage,
                                                                         partsAndEtags: partsAndEtags)

                completeOperation.completionBlock = {

                    let jsonResponse = completeOperation.response

                    // Return response to the user.
                    queue.async {
                        completionHandler(jsonResponse)
                    }
                }

                self.uploadOperationQueue.addOperation(completeOperation)
            }

            self.uploadOperationQueue.addOperation(blockOperation)
        }

        uploadOperationQueue.addOperation(startOperation)
    }
}
