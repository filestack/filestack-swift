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
    // MARK: - Internal Properties

    let uuid = UUID()
    var uploadProgress: ((Progress) -> Void)?
    var completionHandler: (([JSONResponse]) -> Void)?

    private(set) lazy var progress: Progress = {
        let progress = Progress()

        progress.kind = .file
        progress.fileOperationKind = .copying

        return progress
    }()

    // MARK: - Private Properties

    private var pendingUploads = [MultipartUpload]()
    private var uploadResponses = [JSONResponse]()
    private var masterProgressObservers: [NSKeyValueObservation] = []
    private let masterProgress = Progress()

    private let queue: DispatchQueue
    private let config: Config
    private let options: UploadOptions
    private let uploadQueue: DispatchQueue = DispatchQueue(label: "com.filestack.multi-upload-queue")
    private var uploadables: [Uploadable] = []

    // MARK: - Lifecycle

    init(using uploadables: [Uploadable]? = nil, options: UploadOptions, config: Config, queue: DispatchQueue = .main) {
        self.options = options
        self.config = config
        self.queue = queue

        if let uploadables = uploadables {
            self.uploadables = uploadables
            uploadQueue.sync { upload() }
        }
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
        switch state {
        case .notStarted:
            fallthrough
        case .inProgress:
            uploadQueue.sync {
                for upload in pendingUploads {
                    upload.cancel()
                }

                stopUpload()
            }
            return true
        default:
            return false
        }
    }

    @discardableResult func start() -> Bool {
        switch state {
        case .notStarted:
            uploadQueue.sync { uploadNext() }
            return true
        default:
            return false
        }
    }

    // MARK: - DeferredAdd Protocol Implementation

    @discardableResult func add(uploadables: [Uploadable]) -> Bool {
        switch state {
        case .notStarted:
            uploadQueue.sync {
                self.uploadables = uploadables
                upload()
            }
            return true
        default:
            return false
        }
    }
}

// MARK: - Deprecated

extension MultifileUpload {
    @available(*, deprecated, message: "Marked for removal in version 3.0. Use start() instead.")
    func uploadFiles() {
        start()
    }
}

// MARK: - Private Functions

private extension MultifileUpload {
    func removeProgressObservers() {
        masterProgressObservers.removeAll()
    }

    func setupProgressObserver() {
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

    // Enqueue uploadables
    func upload() {
        setupProgressObserver()

        var totalUploadingBytes: UInt64 = 0

        for uploadable in uploadables {
            guard let uploadableSize = uploadable.size else { continue }

            totalUploadingBytes += uploadableSize

            let upload = MultipartUpload(using: uploadable, options: options, config: config, queue: queue)

            // Set upload progress and completion handlers and add upload progress as a child of our main `progress` object
            // so we can track all uploads from our main `progress` object.
            upload.completionHandler = { self.finished(upload: upload, response: $0) }
            // Add `upload.masterProgress` as a child our our `masterProgress`.
            masterProgress.addChild(upload.progress, withPendingUnitCount: Int64(uploadableSize))

            // Append upload to `pendingUploads`.
            pendingUploads.append(upload)
        }

        // Update `fileCompletedCount` and `fileTotalCount`.
        progress.fileTotalCount = pendingUploads.count
        progress.fileCompletedCount = 0

        // Update `totalUnitCount`
        masterProgress.totalUnitCount = Int64(totalUploadingBytes)
    }

    func finished(upload: MultipartUpload, response: JSONResponse) {
        remove(upload: upload)
        uploadResponses.append(response)
        progress.fileCompletedCount = uploadResponses.count
        uploadNext()
    }

    func remove(upload: MultipartUpload) {
        upload.completionHandler = nil
        upload.uploadProgress = nil

        pendingUploads.removeAll { $0 == upload }
    }

    func uploadNext() {
        guard state == .inProgress || state == .notStarted, let nextUpload = pendingUploads.first else {
            stopUpload()
            return
        }

        state = .inProgress

        nextUpload.start()
    }

    func stopUpload() {
        guard state == .inProgress || state == .notStarted else { return }

        removeProgressObservers()

        if progress.completedUnitCount == progress.totalUnitCount {
            state = .completed
        } else {
            state = .cancelled
        }

        var responses = uploadResponses

        while responses.count < uploadables.count {
            responses.append(JSONResponse(with: Error.cancelled))
        }

        queue.async {
            self.completionHandler?(responses)
            // To ensure this object can be properly deallocated we must ensure that any closures are niled,
            // and `currentOperation` object is niled as well.
            self.completionHandler = nil
            self.uploadProgress = nil
        }
    }
}

// MARK: - CustomStringConvertible Conformance

extension MultifileUpload {
    /// :nodoc:
    public var description: String {
        return Tools.describe(subject: self, only: ["currentStatus", "progress"])
    }
}
