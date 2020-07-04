//
//  MultipartUpload.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/18/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/// This class allows uploading a single `Uploadable` item to a given storage location.
class MultipartUpload: Uploader {
    typealias Result = Swift.Result<JSONResponse, Swift.Error>

    // MARK: - Internal Properties

    let uuid = UUID()

    // Closures
    var uploadProgress: ((Progress) -> Void)?
    var completionHandler: ((JSONResponse) -> Void)?

    // Public-facing progress object.
    let progress: Progress = {
        let progress = Progress()

        progress.kind = .file
        progress.fileOperationKind = .copying

        return progress
    }()

    // MARK: - Private Properties

    private var uploadable: Uploadable
    private var masterProgressObservers: [NSKeyValueObservation] = []
    private let masterProgress = Progress()

    private var descriptor: UploadDescriptor?
    private var partsAndEtags: [Int: String]?

    private let queue: DispatchQueue
    private let config: Config
    private let options: UploadOptions

    private let uploadQueue: DispatchQueue = DispatchQueue(label: "com.filestack.upload-queue")

    private lazy var masterOperationQueue: OperationQueue = {
        let operationQueue = OperationQueue()

        operationQueue.maxConcurrentOperationCount = 1

        return operationQueue
    }()

    private lazy var partOperationQueue: OperationQueue = {
        let operationQueue = OperationQueue()

        operationQueue.maxConcurrentOperationCount = options.partUploadConcurrency

        return operationQueue
    }()

    // MARK: - Lifecycle

    init(using uploadable: Uploadable, options: UploadOptions, config: Config, queue: DispatchQueue = .main) {
        self.uploadable = uploadable
        self.options = options
        self.config = config
        self.queue = queue
    }

    // MARK: - Uploadable Protocol Implementation

    private(set) var state: UploadState = .notStarted {
        didSet {
            switch state {
            case .cancelled:
                masterProgress.cancel()
                progress.cancel()
            default:
                break
            }
        }
    }

    @discardableResult func cancel() -> Bool {
        guard state != .cancelled else { return false }

        uploadQueue.sync {
            partOperationQueue.cancelAllOperations()
            masterOperationQueue.cancelAllOperations()
            removeProgressObservers()
            state = .cancelled
        }

        queue.async {
            self.completionHandler?(JSONResponse(with: Error.cancelled))
            self.completionHandler = nil
            self.uploadProgress = nil
        }

        return true
    }

    @discardableResult func start() -> Bool {
        switch state {
        case .notStarted:
            uploadQueue.async { self.upload() }
            return true
        default:
            return false
        }
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
    func removeProgressObservers() {
        masterProgressObservers.removeAll()
    }

    func setupProgressObservers() {
        removeProgressObservers()

        masterProgressObservers.append(masterProgress.observe(\.totalUnitCount, options: [.new]) { progress, _ in
            self.progress.totalUnitCount = progress.totalUnitCount

            self.queue.async {
                self.uploadProgress?(self.progress)
            }
        })

        masterProgressObservers.append(masterProgress.observe(\.fractionCompleted, options: [.new]) { progress, _ in
            self.progress.completedUnitCount = Int64(progress.fractionCompleted * Double(progress.totalUnitCount))

            self.queue.async {
                self.uploadProgress?(self.progress)
            }
        })
    }

    func finish(with result: Result) {
        guard state == .notStarted || state == .inProgress else { return }

        removeProgressObservers()

        switch result {
        case let .success(response):
            state = .completed
            queue.async {
                self.completionHandler?(response)
                self.completionHandler = nil
                self.uploadProgress = nil
            }
        case let .failure(error):
            state = .failed

            queue.async {
                self.completionHandler?(JSONResponse(with: error))
                self.completionHandler = nil
                self.uploadProgress = nil
            }
        }
    }

    func upload() {
        state = .inProgress
        setupProgressObservers()

        // Step 1) Execute start operation
        executeStartOperation { (result) in
            switch result {
            case let .success(descriptor):
                // Set `totalUnitCount` to descriptor's filesize.
                self.masterProgress.totalUnitCount = Int64(descriptor.filesize)

                // Step 2) Execute submit parts operation
                self.executeSubmitPartsOperation(using: descriptor) { (result) in
                    switch result {
                    case let .success(partsAndEtags):
                        guard self.state == .inProgress else { return }

                        // Step 3) Execute complete operation
                        self.executeCompleteOperation(using: partsAndEtags, descriptor: descriptor) { (result) in
                            switch result {
                            case let .success(response):
                                self.finish(with: .success(response))
                            case let .failure(error):
                                self.finish(with: .failure(error))
                            }
                        }
                    case let .failure(error):
                        self.finish(with: .failure(error))
                    }
                }
            case let .failure(error):
                self.finish(with: .failure(error))
            }
        }
    }

    /// Executes the start operation.
    ///
    /// - Parameter completion: On success, returns an `UploadDescriptor`, otherwise returns an error.
    func executeStartOperation(completion: @escaping (StartUploadOperation.Result) -> Void) {
        guard state == .inProgress else { return }

        let filename = options.storeOptions.filename ?? uploadable.filename ?? UUID().uuidString
        let mimeType = options.storeOptions.mimeType ?? uploadable.mimeType ?? "text/plain"

        guard let filesize = uploadable.size, filesize > 0, !filename.isEmpty else {
            finish(with: .failure(Error.custom("The provided uploadable is invalid or cannot be found.")))
            return
        }

        guard let reader = uploadable.reader else {
            finish(with: .failure(Error.custom("Unable to instantiate uploadable data reader.")))
            return
        }

        let startOperation = StartUploadOperation(config: config,
                                                  options: options,
                                                  reader: reader,
                                                  filename: filename,
                                                  filesize: filesize,
                                                  mimeType: mimeType)

        masterOperationQueue.addOperation(startOperation)
        masterOperationQueue.addOperation { completion(startOperation.result) }
    }

    /// Executes the submit parts operation.
    ///
    /// - Parameter descriptor: The `UploadDescriptor` to use as input.
    /// - Parameter completion: On success, returns a `[Int: String]` dictionary with parts and Etags
    /// (will be empty if Intelligent Ingestion is used), otherwise returns an error.
    func executeSubmitPartsOperation(using descriptor: UploadDescriptor, completion: @escaping (SubmitPartsUploadOperation.Result) -> Void) {
        guard state == .inProgress else { return }

        let submitPartsOperation = SubmitPartsUploadOperation(using: descriptor)
        let pendingUnitCount = Int64(descriptor.filesize)

        masterOperationQueue.addOperation(submitPartsOperation)
        masterProgress.addChild(submitPartsOperation.progress, withPendingUnitCount: pendingUnitCount)
        masterOperationQueue.addOperation { completion(submitPartsOperation.result) }
    }

    /// Executes the complete operation.
    ///
    /// - Parameter partsAndEtags: A `[Int: String]` dictionary to use as input.
    /// - Parameter descriptor: The `UploadDescriptor` to use as input.
    /// - Parameter completion: On success, returns a `JSONResponse` containing the response from the API server,
    ///  otherwise returns an error.
    func executeCompleteOperation(using partsAndEtags: [Int: String],
                                  descriptor: UploadDescriptor,
                                  completion: @escaping (CompleteUploadOperation.Result) -> Void) {
        guard state == .inProgress else { return }

        let completeOperation = CompleteUploadOperation(partsAndEtags: partsAndEtags,
                                                        retries: Defaults.maxRetries,
                                                        descriptor: descriptor)

        masterOperationQueue.addOperation(completeOperation)
        masterOperationQueue.addOperation { completion(completeOperation.result) }
    }
}

// MARK: - CustomStringConvertible Conformance

extension MultipartUpload {
    /// :nodoc:
    public var description: String {
        return Tools.describe(subject: self, only: ["currentStatus", "progress"])
    }
}

// MARK: - Defaults

private extension MultipartUpload {
    struct Defaults {
        static let maxRetries = 5
    }
}
