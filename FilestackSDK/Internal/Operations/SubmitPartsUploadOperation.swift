//
//  SubmitPartsUploadOperation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 02/07/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import Foundation

class SubmitPartsUploadOperation: BaseOperation<[Int: String]> {
    // MARK: - Internal Properties

    let descriptor: UploadDescriptor

    private(set) lazy var progress = Progress(totalUnitCount: Int64(descriptor.filesize))

    // MARK: - Private Properties

    private lazy var partOperationQueue: OperationQueue = {
        let operationQueue = OperationQueue()

        operationQueue.maxConcurrentOperationCount = descriptor.options.partUploadConcurrency

        return operationQueue
    }()

    // MARK: - Lifecycle

    init(using descriptor: UploadDescriptor) {
        self.descriptor = descriptor
        super.init()
        state = .ready
    }
}

// MARK: - Overrides

extension SubmitPartsUploadOperation {
    override func main() {
        enqueue(operations: generatePartOperations())
    }

    override func cancel() {
        partOperationQueue.cancelAllOperations()

        super.cancel()
    }
}

private extension SubmitPartsUploadOperation {
    func generatePartOperations() -> [SubmitPartUploadOperation] {
        var operations: [SubmitPartUploadOperation] = []
        var part: Int = 0
        var bytesLeft: UInt64 = descriptor.filesize
        let chunkSize = (descriptor.useIntelligentIngestion ? ChunkSize.ii : ChunkSize.regular).rawValue

        // Enqueue part upload operations.
        while bytesLeft > 0 {
            let offset = (descriptor.filesize - bytesLeft)
            let size = Int(min(UInt64(chunkSize), bytesLeft))

            part += 1
            bytesLeft -= UInt64(size)

            if descriptor.useIntelligentIngestion {
                operations.append(SubmitPartIntelligentUploadOperation(number: part,
                                                                       size: size,
                                                                       offset: offset,
                                                                       descriptor: descriptor))
            } else {
                operations.append(SubmitPartRegularUploadOperation(number: part,
                                                                   size: size,
                                                                   offset: offset,
                                                                   descriptor: descriptor))
            }
        }

        return operations
    }

    func enqueue(operations: [SubmitPartUploadOperation]) {
        var partsAndEtags: [Int: String] = [:]

        // Operation to run after all other operations completed.
        let finalOperation = BlockOperation {
            guard self.state != .finished else { return }

            if !self.descriptor.useIntelligentIngestion && partsAndEtags.isEmpty {
                self.finish(with: .failure(Error.custom("Unable to obtain parts and Etags.")))
            } else {
                self.finish(with: .success(partsAndEtags))
            }
        }

        // Enqueue operations and setup operation dependencies.
        for operation in operations {
            // Validate operation to be executed after a dependent operation finishes running.
            let validateOperation = BlockOperation {
                guard self.state != .finished else { return }

                switch operation.result {
                case let .success(response):
                    // Store parts and ETags, if present.
                    partsAndEtags[operation.number] = response.allHeaderFields["Etag"] as? String
                case let .failure(error):
                    // In case a part submission fails, we will cancel all operations and finish with error.
                    self.partOperationQueue.cancelAllOperations()
                    self.finish(with: .failure(error))
                }
            }

            // Set operation dependencies.
            validateOperation.addDependency(operation)
            finalOperation.addDependency(validateOperation)

            // Enqueue operations.
            partOperationQueue.addOperation(operation)
            partOperationQueue.addOperation(validateOperation)

            // Add `operation.progress` as child of `progress`.
            progress.addChild(operation.progress, withPendingUnitCount: Int64(operation.size))
        }

        // Enqueue `finalOperation`.
        partOperationQueue.addOperation(finalOperation)
    }
}

// MARK: - ChunkSize

private extension SubmitPartsUploadOperation {
    /// Chunksize depending on upload type.
    enum ChunkSize: Int {
        /// Regular (5 megabytes)
        case regular = 5_242_880
        /// Intelligent Ingestion (8 megabytes)
        case ii = 8_388_608
    }
}
