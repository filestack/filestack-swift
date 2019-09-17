//
//  MultifileUpload.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 14/05/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

/// This class allows uploading multiple `Uploadable` items to a given storage location.
class MultifileUpload: Uploader, DeferredAdd {
    // MARK: - Public Properties

    // MARK: - Internal Properties

    internal let masterProgress = MirroredProgress()
    internal var progressHandler: ((Progress) -> Void)?
    internal var completionHandler: (([NetworkJSONResponse]) -> Void)?

    // MARK: - Private Properties

    private var pendingUploads = [MultipartUpload]()
    private var uploadResponses = [NetworkJSONResponse]()

    private var shouldAbort: Bool = false
    private var currentOperation: MultipartUpload?

    private let queue: DispatchQueue
    private let apiKey: String
    private let options: UploadOptions
    private let security: Security?
    private let uploadQueue: DispatchQueue = DispatchQueue(label: "com.filestack.multi-upload-queue")

    // MARK: - Lifecycle Functions

    init(using uploadables: [Uploadable]? = nil,
         options: UploadOptions,
         queue: DispatchQueue = .main,
         apiKey: String,
         security: Security? = nil) {
        self.options = options
        self.queue = queue
        self.apiKey = apiKey
        self.security = security

        if let uploadables = uploadables {
            uploadQueue.sync {
                enqueueUploadables(uploadables: uploadables)
            }
        }
    }

    // MARK: - Uploadable Protocol Implementation

    private(set) var currentStatus: UploadStatus = .notStarted {
        didSet {
            switch currentStatus {
            case .cancelled:
                progress.cancel()
            default:
                break
            }
        }
    }

    lazy var progress = {
        masterProgress.mirror
    }()

    @discardableResult func cancel() -> Bool {
        switch currentStatus {
        case .notStarted:
            fallthrough
        case .inProgress:
            uploadQueue.sync {
                shouldAbort = true
                currentOperation?.cancel()
                stopUpload()
            }

            return true
        default:
            return false
        }
    }

    @discardableResult func start() -> Bool {
        switch currentStatus {
        case .notStarted:
            uploadQueue.sync {
                uploadNextFile()
                updateProgress()
            }

            return true
        default:
            return false
        }
    }

    func uploadFiles() {
        start()
    }

    // MARK: - DeferredAdd Protocol Implementation

    @discardableResult func add(uploadables: [Uploadable]) -> Bool {
        switch currentStatus {
        case .notStarted:
            uploadQueue.sync {
                self.enqueueUploadables(uploadables: uploadables)
            }

            return true
        default:
            return false
        }
    }
}

private extension MultifileUpload {
    // Enqueue uploadables
    private func enqueueUploadables(uploadables: [Uploadable]) {
        // Map uploadables into `MultipartUpload`,
        // discarding uploadables that can't report size (e.g., an unexisting URL.)
        let uploads: [MultipartUpload] = uploadables.compactMap { uploadable in
            guard uploadable.size != nil else { return nil }
            return MultipartUpload(using: uploadable, options: options, queue: queue, apiKey: apiKey, security: security)
        }

        // Append uploads to `pendingUploads`.
        pendingUploads.append(contentsOf: uploads)
        // Update progress total unit count so it matches the `pendingUploads` count.
        masterProgress.totalUnitCount = Int64(pendingUploads.count)

        // Set upload progress and completion handlers and add upload progress as a child of our main `progress` object
        // so we can track all uploads from our main `progress` object.
        for upload in uploads {
            upload.uploadProgress = { _ in self.updateProgress() }
            upload.completionHandler = { self.finishedCurrentFile(with: $0) }

            masterProgress.addChild(upload.masterProgress, withPendingUnitCount: 1)
        }
    }

    func uploadNextFile() {
        guard !shouldAbort, let nextUpload = pendingUploads.first else {
            stopUpload()
            return
        }

        currentStatus = .inProgress
        currentOperation = nextUpload

        nextUpload.start()
    }

    func stopUpload() {
        guard currentStatus != .completed, currentStatus != .cancelled else { return }

        if masterProgress.completedUnitCount == masterProgress.totalUnitCount {
            currentStatus = .completed
        } else {
            currentStatus = .cancelled
        }

        while uploadResponses.count < masterProgress.totalUnitCount {
            uploadResponses.append(NetworkJSONResponse(with: MultipartUploadError.aborted))
        }

        queue.async {
            self.completionHandler?(self.uploadResponses)
            // To ensure this object can be properly deallocated we must ensure that any closures are niled,
            // and `currentOperation` object is niled as well.
            self.completionHandler = nil
            self.progressHandler = nil
            self.currentOperation = nil
        }
    }

    func updateProgress() {
        queue.async {
            self.progressHandler?(self.progress)
        }
    }

    func finishedCurrentFile(with response: NetworkJSONResponse) {
        if !pendingUploads.isEmpty {
            uploadResponses.append(response)
        }

        pendingUploads = Array(pendingUploads.dropFirst())
        uploadNextFile()
    }
}

// MARK: - CustomStringConvertible

extension MultifileUpload {
    /// :nodoc:
    public var description: String {
        return Tools.describe(subject: self, only: ["currentStatus", "progress"])
    }
}
