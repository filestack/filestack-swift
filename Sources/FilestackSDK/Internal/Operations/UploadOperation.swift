//
//  UploadOperation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 05/07/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import Foundation

class UploadOperation: BaseOperation<JSONResponse> {
    // MARK: - Internal Properties

    private(set) lazy var progress: Progress = {
        let progress = Progress()

        progress.kind = .file
        progress.fileOperationKind = .copying
        progress.totalUnitCount = masterProgress.totalUnitCount

        return progress
    }()

    // MARK: - Private Properties

    private let uploadable: Uploadable
    private let config: Config
    private let options: UploadOptions

    private lazy var operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()

        operationQueue.maxConcurrentOperationCount = 1

        return operationQueue
    }()

    private let masterProgress = Progress()
    private var masterProgressObservers: [NSKeyValueObservation] = []
    private let lockQueue = DispatchQueue(label: "com.filestack.FilestackSDK.upload-operation-lock-queue")

    // MARK: - Lifecycle

    required init(uploadable: Uploadable, options: UploadOptions, config: Config) {
        self.uploadable = uploadable
        self.options = options
        self.config = config
        self.masterProgress.totalUnitCount = Int64(uploadable.size ?? 0)

        super.init()
    }

    // MARK: - BaseOperation Overrides

    override func finish(with result: BaseOperation<JSONResponse>.Result) {
        removeProgressObservers()

        super.finish(with: result)
    }
}


// MARK: - Overrides

extension UploadOperation {
    override func main() {
        setupProgressObservers()
        upload()
    }

    override func cancel() {
        super.cancel()

        operationQueue.cancelAllOperations()
    }
}

private extension UploadOperation {
    func setupProgressObservers() {
        lockQueue.sync {
            guard !isCancelled else { return }

            masterProgressObservers.append(masterProgress.observe(\.totalUnitCount) { progress, _ in
                self.progress.totalUnitCount = progress.totalUnitCount
            })

            masterProgressObservers.append(masterProgress.observe(\.fractionCompleted) { progress, _ in
                self.progress.completedUnitCount = Int64(progress.fractionCompleted * Double(progress.totalUnitCount))
            })
        }
    }

    func removeProgressObservers() {
        lockQueue.sync { masterProgressObservers.removeAll() }
    }

    func upload() {
        // Step 1) Execute start operation
        executeStartOperation { (result) in
            switch result {
            case let .success(descriptor):
                // Step 2) Execute submit parts operation
                self.executeSubmitPartsOperation(using: descriptor) { (result) in
                    switch result {
                    case let .success(partsAndEtags):
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
        guard !isCancelled else { return }

        guard let filesize = uploadable.size, filesize > 0 else {
            completion(.failure(.custom("The provided uploadable is either empty or cannot be accessed.")))
            return
        }

        guard let reader = uploadable.reader else {
            completion(.failure(.custom("Unable to instantiate uploadable data reader.")))
            return
        }

        var filename = options.storeOptions.filename ?? uploadable.filename ?? ""
        var mimeType = options.storeOptions.mimeType ?? uploadable.mimeType ?? ""

        if filename.isEmpty { filename = UUID().uuidString }
        if mimeType.isEmpty { mimeType = "text/plain" }

        let startOperation = StartUploadOperation(config: config,
                                                  options: options,
                                                  reader: reader,
                                                  filename: filename,
                                                  filesize: filesize,
                                                  mimeType: mimeType)

        startOperation.completionBlock = { completion(startOperation.result) }

        operationQueue.addOperation(startOperation)
    }

    /// Executes the submit parts operation.
    ///
    /// - Parameter descriptor: The `UploadDescriptor` to use as input.
    /// - Parameter completion: On success, returns a `[Int: String]` dictionary with parts and Etags
    /// (will be empty if Intelligent Ingestion is used), otherwise returns an error.
    func executeSubmitPartsOperation(using descriptor: UploadDescriptor, completion: @escaping (SubmitPartsUploadOperation.Result) -> Void) {
        guard !isCancelled else { return }

        let submitPartsOperation = SubmitPartsUploadOperation(using: descriptor)

        submitPartsOperation.completionBlock = { completion(submitPartsOperation.result) }

        masterProgress.addChild(submitPartsOperation.progress, withPendingUnitCount: Int64(descriptor.filesize))
        operationQueue.addOperation(submitPartsOperation)
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
        guard !isCancelled else { return }

        let completeOperation = CompleteUploadOperation(partsAndEtags: partsAndEtags, descriptor: descriptor)

        completeOperation.completionBlock = { completion(completeOperation.result) }

        operationQueue.addOperation(completeOperation)
    }
}
