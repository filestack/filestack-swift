//
//  MultifileUpload.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 14/05/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

/// This class allows uploading multiple `Uploadable` items to a given storage location.
///
/// Please notice this class can not be directly instantiated. Instances of this class are
/// returned by the upload functions in `Client`.
///
/// Features:
///
/// - Ability to track upload progress (see the `progress` property)
/// - Ability to add `Uploadable` items at any time before the upload starts (see `add(uploadables:)`)
/// - Ability to cancel the upload process (see `cancel()`)
///
@objc(FSMultifileUpload) public class MultifileUpload: NSObject {
    // MARK: - Public Properties

    /// The overall upload progress.
    @objc public let progress = Progress()

    /// Current upload status.
    @objc public private(set) var currentStatus: UploadStatus = .notStarted

    // MARK: - Internal Properties

    internal var uploadProgress: ((Progress) -> Void)?
    internal var completionHandler: (([NetworkJSONResponse]) -> Void)?

    // MARK: - Private Properties

    private var pendingUploads = [MultipartUpload]()
    private var uploadResponses = [NetworkJSONResponse]()

    private var shouldAbort: Bool
    private var currentOperation: MultipartUpload?

    private let queue: DispatchQueue
    private let apiKey: String
    private let options: UploadOptions
    private let security: Security?

    // MARK: - Lifecycle Functions

    init(using uploadables: [Uploadable]? = nil,
         options: UploadOptions,
         queue: DispatchQueue = .main,
         apiKey: String,
         security: Security? = nil) {
        self.options = options
        self.shouldAbort = false
        self.queue = queue
        self.apiKey = apiKey
        self.security = security

        super.init()

        if let uploadables = uploadables {
            enqueueUploadables(uploadables: uploadables)
        }
    }

    // MARK: - Public Functions

    /// Adds items to be uploaded.
    ///
    /// - Important: Any items added after the upload process started will be ignored.
    ///
    /// - Parameter uploadables: An array of `Uploadable` items to upload.
    /// - Returns: True on success, false otherwise.
    @discardableResult public func add(uploadables: [Uploadable]) -> Bool {
        switch currentStatus {
        case .notStarted:
            self.enqueueUploadables(uploadables: uploadables)

            return true
        default:
            return false
        }
    }

    /// Cancels upload.
    ///
    /// - Important: Any already uploaded files **will not** be deleted —
    /// only the current file being uploaded (if any) and any pending files will be affected.
    ///
    /// This will trigger `completionHandler`.
    ///
    /// - Returns: True on success, false otherwise.
    @objc
    @discardableResult public func cancel() -> Bool {
        guard currentStatus != .cancelled else { return false }

        shouldAbort = true
        currentOperation?.cancel()
        stopUpload()

        return true
    }

    /// Starts upload.
    ///
    /// - Returns: True on success, false otherwise.
    @objc
    @discardableResult public func start() -> Bool {
        switch currentStatus {
        case .notStarted:
            uploadNextFile()
            updateProgress()

            return true
        default:
            return false
        }
    }

    /// :nodoc:
    @available(*, deprecated, message: "Marked for removal in version 3.0. Use start() instead.")
    @objc public func uploadFiles() {
        start()
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
        progress.totalUnitCount = Int64(pendingUploads.count)

        // Set upload progress and completion handlers and add upload progress as a child of our main `progress` object
        // so we can track all uploads from our main `progress` object.
        for upload in uploads {
            upload.uploadProgress = { _ in self.updateProgress() }
            upload.completionHandler = { self.finishedCurrentFile(with: $0) }

            progress.addChild(upload.progress, withPendingUnitCount: 1)
        }
    }

    func uploadNextFile() {
        guard shouldAbort == false, let nextUpload = pendingUploads.first else {
            stopUpload()
            return
        }

        currentStatus = .inProgress
        nextUpload.start()
    }

    func stopUpload() {
        guard currentStatus != .completed, currentStatus != .cancelled else { return }

        if progress.completedUnitCount == progress.totalUnitCount {
            currentStatus = .completed
        } else {
            currentStatus = .cancelled
        }

        while uploadResponses.count < progress.totalUnitCount {
            uploadResponses.append(NetworkJSONResponse(with: MultipartUploadError.aborted))
        }

        queue.async {
            self.completionHandler?(self.uploadResponses)
            // To ensure this object can be properly deallocated we must ensure that any closures are niled,
            // and `currentOperation` object is niled as well.
            self.completionHandler = nil
            self.uploadProgress = nil
            self.currentOperation = nil
        }
    }

    func updateProgress() {
        queue.async {
            self.uploadProgress?(self.progress)
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
    public override var description: String {
        return Tools.describe(subject: self, only: ["currentStatus"])
    }
}
