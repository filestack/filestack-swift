//
//  SubmitPartsOperation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 02/07/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import Foundation

class SubmitPartsUploadOperation: BaseOperation {

    let descriptor: UploadDescriptor

    var error: MultipartUpload.Error?

    private(set) lazy var progress = Progress(totalUnitCount: Int64(descriptor.filesize))
    private(set) var partsAndEtags: [Int: String]?

    private lazy var partOperationQueue: OperationQueue = {
        let operationQueue = OperationQueue()

        operationQueue.maxConcurrentOperationCount = descriptor.options.partUploadConcurrency

        return operationQueue
    }()

    init(using descriptor: UploadDescriptor) {
        self.descriptor = descriptor
        super.init()
        state = .ready
    }
}

// MARK: - Overrides

extension SubmitPartsUploadOperation {
    override func main() {
        observePartOperationsQueue()

        for operation in partOperations() {
            progress.addChild(operation.progress, withPendingUnitCount: Int64(operation.partSize))
            partOperationQueue.addOperation(operation)
        }
    }

    override func cancel() {
        super.cancel()

        partOperationQueue.cancelAllOperations()
    }
}

private extension SubmitPartsUploadOperation {
    func fail(with someError: MultipartUpload.Error) {
        error = someError
        state = .finished
    }

    func observePartOperationsQueue() {
        var observer: NSKeyValueObservation?

        observer = partOperationQueue.observe(\.operations, options: [.new]) { (queue, change) in
            guard let operations = change.newValue as? [MultipartUploadSubmitPartOperation] else { return }

            if (operations.contains { $0.didFail }) {
                self.partOperationQueue.cancelAllOperations()
                self.fail(with: .custom(description: "Part operation did fail."))

                return
            }

            if operations.count == 0 {
                observer?.invalidate()

                var partsAndEtags: [Int: String] = [:]

                for operation in operations {
                    if let responseEtag = operation.responseEtag {
                        partsAndEtags[operation.part] = responseEtag
                    }
                }

                if !self.descriptor.useIntelligentIngestion && partsAndEtags.isEmpty {
                    self.fail(with: .custom(description: "Unable to obtain parts and Etags."))
                } else {
                    self.partsAndEtags = partsAndEtags
                    self.state = .finished
                }
            }
        }
    }

    func partOperations() -> [MultipartUploadSubmitPartOperation] {
        var part: Int = 0
        var bytesLeft: UInt64 = descriptor.filesize
        var operations: [MultipartUploadSubmitPartOperation] = []
        let chunkSize = (descriptor.useIntelligentIngestion ? Defaults.ChunkSize.ii : Defaults.ChunkSize.regular).rawValue

        // Add operations to array.
        while bytesLeft > 0 {
            let offset = (descriptor.filesize - bytesLeft)
            let partSize = Int(min(UInt64(chunkSize), bytesLeft))

            part += 1
            bytesLeft -= UInt64(partSize)

            if descriptor.useIntelligentIngestion {
                operations.append(MultipartIntelligentUploadSubmitPartOperation(offset: offset,
                                                                                part: part,
                                                                                partSize: partSize,
                                                                                descriptor: descriptor))
            } else {
                operations.append(MultipartRegularUploadSubmitPartOperation(offset: offset,
                                                                            part: part,
                                                                            partSize: partSize,
                                                                            descriptor: descriptor))
            }
        }

        return operations
    }
}

// MARK: - Defaults

private extension SubmitPartsUploadOperation {
    struct Defaults {
        static let maxRetries = 5

        /// Chunksize depending on upload type.
        enum ChunkSize: Int {
            /// Regular (5 megabytes)
            case regular = 5_242_880
            /// Intelligent Ingestion (8 megabytes)
            case ii = 8_388_608
        }
    }
}
