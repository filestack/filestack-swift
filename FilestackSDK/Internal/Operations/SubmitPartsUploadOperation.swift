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

    private lazy var operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()

        operationQueue.maxConcurrentOperationCount = descriptor.options.partUploadConcurrency

        return operationQueue
    }()

    // MARK: - Lifecycle

    init(using descriptor: UploadDescriptor) {
        self.descriptor = descriptor

        super.init()
    }
}

// MARK: - Overrides

extension SubmitPartsUploadOperation {
    override func main() {
        enqueue(operations: generatePartOperations())
    }

    override func cancel() {
        super.cancel()

        operationQueue.cancelAllOperations()
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

        var completeCount = 0

        // Enqueue operations and setup operation dependencies.
        for operation in operations {
            // Validate operation to be executed after a dependent operation finishes running.
            operation.completionBlock = {
                completeCount += 1

                switch operation.result {
                case let .success(response):
                    // Store parts and ETags, if present.
                    if let etag = response.allHeaderFields["Etag"] as? String {
                        partsAndEtags[operation.number] = etag.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
                    }
                case let .failure(error):
                    // In case a part submission fails, we will cancel all operations and finish with error.
                    self.operationQueue.cancelAllOperations()
                    self.finish(with: .failure(error))
                    return
                }

                if completeCount == operations.count {
                    if !self.descriptor.useIntelligentIngestion && partsAndEtags.isEmpty {
                        self.finish(with: .failure(.custom("Unable to obtain parts and Etags.")))
                    } else {
                        self.finish(with: .success(partsAndEtags))
                    }
                }
            }

            // Enqueue operations.
            operationQueue.addOperation(operation)

            // Add `operation.progress` as child of `progress`.
            progress.addChild(operation.progress, withPendingUnitCount: Int64(operation.size))
        }
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
