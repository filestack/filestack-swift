//
//  MultipartIntelligentUploadSubmitPartOperation.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 26/09/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Alamofire
import Foundation

internal class MultipartIntelligentUploadSubmitPartOperation: BaseOperation, MultipartUploadSubmitPartProtocol {
    let resumableMobileChunkSize = 1 * Int(pow(Double(1024), Double(2)))
    let resumableDesktopChunkSize = 8 * Int(pow(Double(1024), Double(2)))
    let minimumPartChunkSize = 32768

    let offset: UInt64
    let part: Int
    let partSize: Int
    let maxRetries: Int = 5

    private(set) lazy var progress: Progress = {
        let progress = MirroredProgress()

        progress.totalUnitCount = Int64(partSize)

        return progress
    }()

    var response: DefaultDataResponse?
    var responseEtag: String?
    var didFail: Bool = false

    private lazy var retriesLeft: Int = maxRetries
    private var chunkSize: Int = 0

    private var beforeCommitCheckPointOperation: BlockOperation?
    private let chunkUploadOperationUnderlyingQueue = DispatchQueue(label: "com.filestack.chunk-upload-operation-queue",
                                                                    qos: .utility,
                                                                    attributes: .concurrent)

    private(set) lazy var chunkUploadOperationQueue: OperationQueue = {
        let queue = OperationQueue()

        queue.underlyingQueue = chunkUploadOperationUnderlyingQueue
        queue.maxConcurrentOperationCount = descriptor.options.chunkUploadConcurrency

        return queue
    }()

    private let descriptor: MultipartUploadDescriptor

    required init(offset: UInt64, part: Int, partSize: Int, descriptor: MultipartUploadDescriptor) {
        self.offset = offset
        self.part = part
        self.partSize = partSize
        self.descriptor = descriptor

        super.init()

        state = .ready
    }

    override func main() {
        upload()
    }

    override func cancel() {
        super.cancel()
        didFail = true
        chunkUploadOperationQueue.cancelAllOperations()
    }
}

private extension MultipartIntelligentUploadSubmitPartOperation {
    func upload() {
        chunkSize = resumableMobileChunkSize

        beforeCommitCheckPointOperation = BlockOperation()

        beforeCommitCheckPointOperation?.completionBlock = {
            self.doCommit()
        }

        var bytesRead: UInt64 = 0

        while bytesRead < UInt64(partSize) {
            if isCancelled || isFinished {
                chunkUploadOperationQueue.cancelAllOperations()
                break
            }

            // Guard against EOF
            guard let chunkOperation = addChunkOperation(offset: offset + bytesRead, chunkSize: chunkSize) else { break }

            let actualChunkSize = chunkOperation.progress.totalUnitCount

            progress.addChild(chunkOperation.progress, withPendingUnitCount: Int64(actualChunkSize))
            bytesRead += UInt64(actualChunkSize)
        }

        if let beforeCommitCheckPointOperation = beforeCommitCheckPointOperation {
            chunkUploadOperationQueue.addOperation(beforeCommitCheckPointOperation)
        }
    }

    private func doCommit() {
        // Try to commit operation with retries.
        while !didFail, retriesLeft > 0 {
            let commitOperation = MultipartUploadCommitOperation(descriptor: descriptor, part: part)

            chunkUploadOperationQueue.addOperation(commitOperation)
            chunkUploadOperationQueue.waitUntilAllOperationsAreFinished()

            let jsonResponse = commitOperation.response
            let isNetworkError = jsonResponse?.response == nil && jsonResponse?.error != nil

            // Check for any error response.
            if jsonResponse?.response?.statusCode != 200 || isNetworkError, retriesLeft > 0 {
                let delay = isNetworkError ? 0 : pow(2, Double(maxRetries - retriesLeft))
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

        state = .finished
        beforeCommitCheckPointOperation = nil
    }

    private func addChunkOperation(offset: UInt64, chunkSize: Int) -> MultipartUploadSubmitChunkOperation? {
        descriptor.reader.seek(position: offset)

        let dataChunk = descriptor.reader.read(amount: chunkSize)

        guard !dataChunk.isEmpty else { return nil }

        let operation = MultipartUploadSubmitChunkOperation(offset: offset,
                                                            chunk: dataChunk,
                                                            part: part,
                                                            descriptor: descriptor)

        weak var weakOperation = operation

        let checkpointOperation = BlockOperation {
            guard let operation = weakOperation else { return }
            guard operation.isCancelled == false else { return }

            if operation.receivedResponse?.error != nil {
                // Network error
                guard self.retriesLeft > 0 else {
                    self.failOperation()
                    return
                }

                self.retriesLeft -= 1

                guard self.addChunkOperation(offset: operation.offset, chunkSize: self.chunkSize) != nil else { return }
            } else if let response = operation.receivedResponse?.response {
                switch response.statusCode {
                case 200:
                    // NO-OP
                    break
                default:
                    // Server error
                    guard chunkSize > self.minimumPartChunkSize else {
                        self.failOperation()
                        return
                    }

                    // Enqueue 2 chunks corresponding to the 2 halves of the failed chunk.
                    let newPartChunkSize = chunkSize / 2
                    self.chunkSize = newPartChunkSize
                    var partOffset = operation.offset

                    for _ in 1 ... 2 {
                        guard self.addChunkOperation(offset: partOffset,
                                                     chunkSize: newPartChunkSize) != nil else { break }

                        partOffset += UInt64(newPartChunkSize)
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

    func failOperation() {
        didFail = true
        state = .finished
        chunkUploadOperationQueue.cancelAllOperations()
    }
}
