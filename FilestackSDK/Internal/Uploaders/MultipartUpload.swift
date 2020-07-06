//
//  MultipartUpload.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/18/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/// This class allows uploading a single `Uploadable` item to a given storage location.
class MultipartUpload: Uploader, DeferredAdd {
    typealias Result = Swift.Result<[JSONResponse], Error>

    // MARK: - Internal Properties

    let uuid = UUID()

    // Closures
    var uploadProgress: ((Progress) -> Void)?
    var completionHandler: (([JSONResponse]) -> Void)?

    // Public-facing progress object.
    let progress: Progress = {
        let progress = Progress()

        progress.kind = .file
        progress.fileOperationKind = .copying

        return progress
    }()

    // MARK: - Private Properties

    private var uploadables: [Uploadable]?
    private let uploadQueue: DispatchQueue = DispatchQueue(label: "com.filestack.upload-queue")
    private let masterProgress = Progress()
    private var progressObservers: [NSKeyValueObservation] = []

    private let queue: DispatchQueue
    private let config: Config
    private let options: UploadOptions

    private lazy var operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()

        operationQueue.maxConcurrentOperationCount = 1

        return operationQueue
    }()

    // MARK: - Lifecycle

    init(using uploadables: [Uploadable]? = nil, options: UploadOptions, config: Config, queue: DispatchQueue = .main) {
        self.uploadables = uploadables
        self.options = options
        self.config = config
        self.queue = queue
    }

    // MARK: - Uploadable Protocol Implementation

    private(set) var state: UploadState = .notStarted

    @discardableResult func cancel() -> Bool {
        guard state != .cancelled else { return false }

        uploadQueue.sync {
            state = .cancelled
            operationQueue.cancelAllOperations()
        }

        return true
    }

    @discardableResult func start() -> Bool {
        guard state == .notStarted else { return false }

        uploadQueue.sync { upload() }

        return true
    }

    @discardableResult func add(uploadables: [Uploadable]) -> Bool {
        guard state == .notStarted else { return false }

        uploadQueue.sync {
            if self.uploadables != nil {
                self.uploadables?.append(contentsOf: uploadables)
            } else {
                self.uploadables = uploadables
            }
        }

        return true
    }
}

// MARK: - Deprecated

extension MultipartUpload {
    @available(*, deprecated, message: "Marked for removal in version 3.0. Use start() instead.")
    func uploadFiles() {
        start()
    }
}

// MARK: - Private Functions

private extension MultipartUpload {
    /// Starts the upload process.
    func upload() {
        guard let uploadables = uploadables else { return }

        state = .inProgress

        var results: [JSONResponse] = []

        // Observe changes in `progress.fractionCompleted`.
        progressObservers.append(masterProgress.observe(\.fractionCompleted, options: [.new]) { progress, _ in
            self.progress.completedUnitCount = Int64(progress.fractionCompleted * Double(progress.totalUnitCount))
            self.progress.totalUnitCount = progress.totalUnitCount

            self.queue.async {
                self.uploadProgress?(self.progress)
            }
        })

        for uploadable in uploadables {
            let operation = UploadOperation(uploadable: uploadable, options: options, config: config)

            // Block to run when operation completes.
            operation.completionBlock = {
                if let fileCompletedCount = self.progress.fileCompletedCount {
                    self.progress.fileCompletedCount = fileCompletedCount + 1
                }

                switch operation.result {
                case let .success(response):
                    // Append success JSONResponse to `results`.
                    results.append(response)
                case let .failure(error):
                    // Append error JSONResponse to `results`.
                    results.append(JSONResponse(with: error))
                    // Substract failed operation's `totalUnitCount` from globalProgress's `totalUnitCount`.
                    self.masterProgress.totalUnitCount -= operation.progress.totalUnitCount
                }

                if results.count == uploadables.count {
                    // Finish.
                    self.uploadQueue.async {
                        self.finish(with: results)
                    }
                }
            }

            // Add operations.
            operationQueue.addOperation(operation)

            // Update master progress.
            masterProgress.addChild(operation.progress, withPendingUnitCount: operation.progress.totalUnitCount)
            masterProgress.totalUnitCount += operation.progress.totalUnitCount
        }

        progress.fileCompletedCount = 0
        progress.fileTotalCount = uploadables.count
    }

    /// Marks upload process as finished by updating `state` and calling `completionHandler` with return `results`.
    func finish(with results: [JSONResponse]) {
        progressObservers.removeAll()

        // Update state to `completed` unless it is already in `cancelled` state.
        if state != .cancelled {
            state = .completed
        }

        queue.async {
            self.completionHandler?(results)
            self.completionHandler = nil
            self.uploadProgress = nil
        }
    }
}

// MARK: - CustomStringConvertible Conformance

extension MultipartUpload {
    /// :nodoc:
    public var description: String {
        return Tools.describe(subject: self, only: ["state", "progress"])
    }
}
