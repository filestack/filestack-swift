//
//  MultipartUploadSubmitPartOperation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/20/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import Alamofire


internal class MultipartUploadSubmitPartOperation: BaseOperation {

    let resumableMobileChunkSize = 1 * Int(pow(Double(1024), Double(2)))
    let resumableDesktopChunkSize = 8 * Int(pow(Double(1024), Double(2)))
    let minimumPartChunkSize = 32768

    let seek: UInt64
    let localURL: URL
    let fileName: String
    let fileSize: UInt64
    let apiKey: String
    let part: Int
    let uri: String
    let region: String
    let uploadID: String
    let storageLocation: StorageLocation
    let chunkSize: Int
    let useIntelligentIngestion: Bool
    var uploadProgress: ((Int64) -> Void)?
    let maxRetries: Int

    var response: DefaultDataResponse?
    var responseEtag: String?
    var didFail: Bool

    private var retriesLeft: Int
    private var fileHandle: FileHandle?
    private var partChunkSize: Int

    private var beforeCommitCheckPointOperation: BlockOperation?

    private let chunkUploadOperationQueue: OperationQueue = {

        $0.underlyingQueue = DispatchQueue(label: "com.filestack.chunk-upload-operation-queue",
                                           qos: .utility,
                                           attributes: .concurrent)

        return $0
    }(OperationQueue())


    required init(seek: UInt64,
                  localURL: URL,
                  fileName: String,
                  fileSize: UInt64,
                  apiKey: String,
                  part: Int,
                  uri: String,
                  region: String,
                  uploadID: String,
                  storageLocation: StorageLocation,
                  chunkSize: Int,
                  chunkUploadConcurrency: Int,
                  useIntelligentIngestion: Bool,
                  uploadProgress: @escaping ((Int64) -> Void)) {

        self.seek = seek
        self.localURL = localURL
        self.fileName = fileName
        self.fileSize = fileSize
        self.apiKey = apiKey
        self.part = part
        self.uri = uri
        self.region = region
        self.uploadID = uploadID
        self.storageLocation = storageLocation
        self.chunkSize = chunkSize
        self.useIntelligentIngestion = useIntelligentIngestion
        self.partChunkSize = 0
        self.maxRetries = 5
        self.retriesLeft = maxRetries
        self.didFail = false
        self.uploadProgress = uploadProgress
        self.chunkUploadOperationQueue.maxConcurrentOperationCount = chunkUploadConcurrency

        super.init()

        self.isReady = true
    }

    override func main() {

        fileHandle = try? FileHandle(forReadingFrom: self.localURL)

        guard fileHandle != nil else {
            self.isExecuting = false
            self.isFinished = true
            return
        }

        if useIntelligentIngestion {
            intelligentIngestionUpload()
        } else {
            regularUpload()
        }
    }

    override func cancel() {

        didFail = true
        chunkUploadOperationQueue.cancelAllOperations()
        isCancelled = true
    }

    // MARK: - Private Functions

    private func regularUpload() {

        guard !isCancelled, let fileHandle = fileHandle else {
            isExecuting = false
            isFinished = true
            return
        }

        isExecuting = true

        fileHandle.seek(toFileOffset: self.seek)

        let dataChunk = fileHandle.readData(ofLength: chunkSize)

        fileHandle.closeFile()

        let multipartFormData: (MultipartFormData) -> Void = { form in
            form.append(self.apiKey.data(using: .utf8)!, withName: "apikey")
            form.append(self.uri.data(using: .utf8)!, withName: "uri")
            form.append(self.region.data(using: .utf8)!, withName: "region")
            form.append(self.uploadID.data(using: .utf8)!, withName: "upload_id")
            form.append("\(dataChunk.count)".data(using: .utf8)!, withName: "size")
            form.append("\(self.part)".data(using: .utf8)!, withName: "part")
            form.append(dataChunk.base64MD5Digest().data(using: .utf8)!, withName: "md5")
            form.append(String(describing: self.storageLocation).data(using: .utf8)!, withName: "store_location")
        }

        let url = URL(string: "multipart/upload", relativeTo: uploadService.baseURL)!

        uploadService.upload(multipartFormData: multipartFormData, url: url) { response in
            guard let urlString = response.json?["url"] as? String, let url = URL(string: urlString) else {
                self.isExecuting = false
                self.isFinished = true
                return
            }

            guard let headers = response.json?["headers"] as? [String: String] else {
                self.isExecuting = false
                self.isFinished = true
                return
            }

            let uploadRequest = uploadService.upload(data: dataChunk, to: url, method: .put, headers: headers)

            uploadRequest.response { response in
                let chunkSize = Int64(dataChunk.count)
                self.response = response
                self.responseEtag = response.response?.allHeaderFields["Etag"] as? String
                self.isExecuting = false
                self.isFinished = true
                self.uploadProgress?(chunkSize)
                self.uploadProgress = nil
            }
        }
    }

    private func intelligentIngestionUpload() {

        guard !isCancelled else {
            isExecuting = false
            isFinished = true
            return
        }

        isExecuting = true
        partChunkSize = resumableMobileChunkSize

        beforeCommitCheckPointOperation = BlockOperation()

        beforeCommitCheckPointOperation?.completionBlock = {
            self.doCommit()
        }

        var partOffset: UInt64 = 0

        while partOffset < UInt64(chunkSize) {
            if isCancelled || isFinished {
                chunkUploadOperationQueue.cancelAllOperations()
                break
            }

            guard let chunkOperation = addChunkOperation(partOffset: partOffset,
                                                         partChunkSize: partChunkSize) else {
                // EOF condition
                break
            }

            partOffset += UInt64(chunkOperation.dataChunk.count)
        }

        if let beforeCommitCheckPointOperation = beforeCommitCheckPointOperation {
            chunkUploadOperationQueue.addOperation(beforeCommitCheckPointOperation)
        }
    }

    private func doCommit() {

        // Try to commit operation with retries.
        while !didFail && retriesLeft > 0 {
            let commitOperation = MultipartUploadCommitOperation(apiKey: self.apiKey,
                                                                 fileSize: self.fileSize,
                                                                 part: self.part,
                                                                 uri: self.uri,
                                                                 region: self.region,
                                                                 uploadID: self.uploadID,
                                                                 storageLocation: self.storageLocation)

            chunkUploadOperationQueue.addOperation(commitOperation)
            chunkUploadOperationQueue.waitUntilAllOperationsAreFinished()

            let jsonResponse = commitOperation.response
            let isNetworkError = jsonResponse?.response == nil && jsonResponse?.error != nil

            // Check for any error response.
            if (jsonResponse?.response?.statusCode != 200 || isNetworkError) && retriesLeft > 0 {
                let delay = isNetworkError ? 0 : pow(2, Double(self.maxRetries - retriesLeft))
                // Retrying in `delay` seconds
                Thread.sleep(forTimeInterval: delay)
            } else {
                break
            }

            retriesLeft -= 1
        }

        if retriesLeft == 0 {
            didFail = true
        }

        fileHandle = nil
        uploadProgress = nil
        isExecuting = false
        isFinished = true
        beforeCommitCheckPointOperation = nil
    }

    private func addChunkOperation(partOffset: UInt64,
                                   partChunkSize: Int) -> MultipartUploadSubmitChunkOperation? {

        guard let fileHandle = fileHandle else { return nil }

        fileHandle.seek(toFileOffset: self.seek + partOffset)
        let dataChunk = fileHandle.readData(ofLength: partChunkSize)

        guard dataChunk.count > 0 else { return nil }

        let operation = MultipartUploadSubmitChunkOperation(partOffset: partOffset,
                                                            dataChunk: dataChunk,
                                                            apiKey: self.apiKey,
                                                            part: part,
                                                            uri: uri,
                                                            region: region,
                                                            uploadID: uploadID,
                                                            storageLocation: storageLocation)
        weak var weakOperation = operation

        let checkpointOperation = BlockOperation {
            guard let operation = weakOperation else { return }
            guard operation.isCancelled == false else { return }

            // Network error
            if operation.response?.error != nil {
                guard self.retriesLeft > 0 else {
                    self.didFail = true
                    self.isExecuting = false
                    self.isFinished = true
                    self.chunkUploadOperationQueue.cancelAllOperations()
                    return
                }

                self.retriesLeft -= 1

                guard self.addChunkOperation(partOffset: operation.partOffset,
                                             partChunkSize: self.partChunkSize) != nil else {
                    return
                }
            // Server error
            } else if let response = operation.response?.response {
                switch response.statusCode {
                case 200:

                    let chunkSize = Int64(dataChunk.count)
                    self.uploadProgress?(chunkSize)

                default:

                    guard partChunkSize > self.minimumPartChunkSize else {
                        self.didFail = true
                        self.isExecuting = false
                        self.isFinished = true
                        self.chunkUploadOperationQueue.cancelAllOperations()
                        return
                    }

                    // Enqueue 2 chunks corresponding to the 2 halves of the failed chunk.
                    let newPartChunkSize = partChunkSize / 2
                    self.partChunkSize = newPartChunkSize
                    var localPartOffset = operation.partOffset

                    for _ in 1...2 {
                        guard self.addChunkOperation(partOffset: localPartOffset,
                                                    partChunkSize: newPartChunkSize) != nil else {
                            break
                        }

                        localPartOffset += UInt64(newPartChunkSize)
                    }
                }
            }
        }

        checkpointOperation.addDependency(operation)
        chunkUploadOperationQueue.addOperation(operation)
        chunkUploadOperationQueue.addOperation(checkpointOperation)

        beforeCommitCheckPointOperation?.addDependency(operation)
        beforeCommitCheckPointOperation?.addDependency(checkpointOperation)

        return operation
    }
}
