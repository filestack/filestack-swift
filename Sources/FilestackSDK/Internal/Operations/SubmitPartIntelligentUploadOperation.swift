//
//  SubmitPartIntelligentUploadOperation.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 26/09/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

class SubmitPartIntelligentUploadOperation: BaseOperation<HTTPURLResponse>, SubmitPartUploadOperation {
    // MARK: - Internal Properties

    let number: Int
    let size: Int
    let offset: UInt64
    let descriptor: UploadDescriptor

    private(set) lazy var progress = Progress(totalUnitCount: Int64(size))

    // MARK: - Private Properties

    private lazy var chunkUploadOperationQueue: OperationQueue = {
        let queue = OperationQueue()

        queue.maxConcurrentOperationCount = descriptor.options.chunkUploadConcurrency

        return queue
    }()

    // MARK: - Lifecycle

    required init(number: Int, size: Int, offset: UInt64, descriptor: UploadDescriptor) {
        self.number = number
        self.size = size
        self.offset = offset
        self.descriptor = descriptor

        super.init()
    }
}

// MARK: - Operation Overrides

extension SubmitPartIntelligentUploadOperation {
    override func main() {
        upload()
    }

    override func cancel() {
        super.cancel()

        chunkUploadOperationQueue.cancelAllOperations()
    }
}

// MARK: - Private Functions

private extension SubmitPartIntelligentUploadOperation {
    func upload() {
        let chunkSize = Defaults.resumableMobileChunkSize
        var chunkOffset: UInt64 = 0
        let finishOperation = BlockOperation { self.executeCommit() }

        while !isCancelled, chunkOffset < UInt64(size) {
            // Guard against EOF
            guard let chunkOperation = submitChunk(chunkOffset: chunkOffset, chunkSize: chunkSize) else { break }

            finishOperation.addDependency(chunkOperation)

            let actualChunkSize = chunkOperation.progress.totalUnitCount

            progress.addChild(chunkOperation.progress, withPendingUnitCount: Int64(actualChunkSize))
            chunkOffset += UInt64(actualChunkSize)
        }

        chunkUploadOperationQueue.addOperation(finishOperation)
    }

    func submitChunk(chunkOffset: UInt64, chunkSize: Int, retries: Int = Defaults.maxRetries) -> SubmitChunkUploadOperation? {
        guard !isCancelled else { return nil }

        guard retries > 0 else {
            finish(with: .failure(.custom("Exceeded max retries trying to submit data chunk.")))
            return nil
        }

        let operation = SubmitChunkUploadOperation(partOffset: self.offset,
                                                   offset: chunkOffset,
                                                   size: chunkSize,
                                                   part: number,
                                                   descriptor: descriptor)

        operation.completionBlock = {
            guard !self.isCancelled, !operation.isCancelled else { return }

            // Ensure the operation succeeded, or retry again up to `retries` times.
            switch operation.result {
            case let .success(response):
                if response.statusCode != 200 {
                    // Halve the chunk size and try again.
                    let chunkSize = operation.size / 2

                    guard chunkSize > Defaults.minimumPartChunkSize else {
                        self.cancel()
                        return
                    }

                    var partOffset = operation.offset

                    // Enqueue 2 chunks corresponding to the 2 halves of the failed chunk.
                    for _ in 1 ... 2 {
                        guard self.submitChunk(chunkOffset: partOffset,
                                               chunkSize: chunkSize) != nil else { break }

                        partOffset += UInt64(chunkSize)
                    }
                }
            case .failure(_):
                // Try again.
                guard self.submitChunk(chunkOffset: operation.offset,
                                       chunkSize: operation.size,
                                       retries: retries - 1) != nil else { return }
            }
        }

        chunkUploadOperationQueue.addOperation(operation)

        return operation
    }

    func executeCommit() {
        guard !isCancelled else { return }

        let commitOperation = CommitPartUploadOperation(descriptor: descriptor, part: number)

        commitOperation.completionBlock = {
            switch commitOperation.result {
            case let .success(response):
                self.finish(with: .success(response))
            case let .failure(error):
                self.finish(with: .failure(error))
            }
        }

        chunkUploadOperationQueue.addOperation(commitOperation)
    }
}

// MARK: - Defaults

private extension SubmitPartIntelligentUploadOperation {
    struct Defaults {
        static let resumableMobileChunkSize = 1_048_576
        static let resumableDesktopChunkSize = 8_388_608
        static let minimumPartChunkSize = 32_768
        static let maxRetries = 5
    }
}
