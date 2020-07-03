//
//  SubmitPartIntelligentUploadOperation.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 26/09/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Alamofire
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

        state = .ready
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

        while !isCancelled, !isFinished, chunkOffset < UInt64(size) {
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
            self.finish(with: .failure(Error.custom("Too many retries.")))
            return nil
        }

        descriptor.reader.seek(position: offset + chunkOffset)

        let data = descriptor.reader.read(amount: chunkSize)
        let operation = SubmitChunkUploadOperation(data: data, offset: chunkOffset, part: number, descriptor: descriptor)
        let validateOperation = self.validateOperation(for: operation, retries: retries)

        validateOperation.addDependency(operation)
        chunkUploadOperationQueue.addOperation(operation)
        chunkUploadOperationQueue.addOperation(validateOperation)

        return operation
    }

    // Ensures a submit chunk operation succeeded, or retries again up to `retries` times.
    func validateOperation(for chunkOperation: SubmitChunkUploadOperation, retries: Int) -> Operation {
        return BlockOperation {
            switch chunkOperation.result {
            case .success(let response):
                if response.statusCode != 200 {
                    // Halve the chunk size and try again.
                    let chunkSize = chunkOperation.data.count / 2

                    guard chunkSize > Defaults.minimumPartChunkSize else {
                        self.cancel()
                        return
                    }

                    var partOffset = chunkOperation.offset

                    // Enqueue 2 chunks corresponding to the 2 halves of the failed chunk.
                    for _ in 1 ... 2 {
                        guard self.submitChunk(chunkOffset: partOffset,
                                               chunkSize: chunkSize) != nil else { break }

                        partOffset += UInt64(chunkSize)
                    }
                }
            case .failure(_):
                // Try again.
                guard self.submitChunk(chunkOffset: chunkOperation.offset,
                                       chunkSize: chunkOperation.data.count,
                                       retries: retries - 1) != nil else { return }
            }
        }
    }

    func executeCommit() {
        guard state != .finished else { return }

        let commitOperation = CommitPartUploadOperation(descriptor: descriptor, part: number, retries: Defaults.maxRetries)

        let finalizeOperation = BlockOperation {
            switch commitOperation.result {
            case let .success(response):
                self.finish(with: .success(response))
            case let .failure(error):
                self.finish(with: .failure(error))
            }
        }

        finalizeOperation.addDependency(commitOperation)
        chunkUploadOperationQueue.addOperation(commitOperation)
        chunkUploadOperationQueue.addOperation(finalizeOperation)
    }
}

// MARK: - Defaults

private extension SubmitPartIntelligentUploadOperation {
    struct Defaults {
        static let resumableMobileChunkSize = 1 * Int(pow(Double(1024), Double(2)))
        static let resumableDesktopChunkSize = 8 * Int(pow(Double(1024), Double(2)))
        static let minimumPartChunkSize = 32768
        static let maxRetries: Int = 5
    }
}
