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
    @objc public lazy var progress: Progress = {
        Progress(totalUnitCount: Int64(totalSize))
    }()

    /// Current upload status.
    @objc public private(set) var currentStatus: UploadStatus = .notStarted

    // MARK: - Internal Properties

    internal var uploadProgress: ((Progress) -> Void)?
    internal var completionHandler: (([NetworkJSONResponse]) -> Void)?

    // MARK: - Private Properties

    private var uploadables: [Uploadable]
    private var pendingUploadables: [Uploadable]

    private var uploadResponses: [NetworkJSONResponse] = []

    private var finishedFilesSize: Int64
    private var currentFileSize: Int64

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
        self.uploadables = uploadables ?? []
        self.pendingUploadables = uploadables ?? []
        self.options = options
        self.shouldAbort = false
        self.queue = queue
        self.apiKey = apiKey
        self.security = security
        self.finishedFilesSize = 0
        self.currentFileSize = 0
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
            self.uploadables.append(contentsOf: uploadables)
            pendingUploadables.append(contentsOf: uploadables)

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
            showMinimalProgress()

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
    var totalSize: UInt64 {
        return (uploadables.compactMap { $0.size }).reduce(UInt64(0)) { sum, size in sum + size }
    }

    func showMinimalProgress() {
        let minimalProgress = Progress(totalUnitCount: 100)
        minimalProgress.completedUnitCount = 1
        updateProgress(minimalProgress)
    }

    func uploadNextFile() {
        guard shouldAbort == false, let nextUploadable = pendingUploadables.first, let size = nextUploadable.size else {
            stopUpload()
            return
        }

        currentStatus = .inProgress
        currentFileSize = Int64(size)
        currentOperation = MultipartUpload(using: nextUploadable,
                                           options: options,
                                           queue: queue,
                                           apiKey: apiKey,
                                           security: security)

        currentOperation?.uploadProgress = { progress in
            self.updateProgress(progress)
        }

        currentOperation?.completionHandler = { response in
            self.finishedCurrentFile(with: response)
        }

        currentOperation?.start()
    }

    func stopUpload() {
        guard currentStatus != .completed, currentStatus != .cancelled else { return }

        if progress.completedUnitCount == progress.totalUnitCount {
            currentStatus = .completed
        } else {
            currentStatus = .cancelled
        }

        while uploadResponses.count < pendingUploadables.count {
            uploadResponses.append(NetworkJSONResponse(with: MultipartUploadError.aborted))
            pendingUploadables = Array(pendingUploadables.dropFirst())
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

    func updateProgress(_ currentFileProgress: Progress) {
        currentFileSize = currentFileProgress.completedUnitCount
        progress.completedUnitCount = finishedFilesSize + currentFileSize

        queue.async {
            self.uploadProgress?(self.progress)
        }
    }

    func finishedCurrentFile(with response: NetworkJSONResponse) {
        finishedFilesSize += currentFileSize

        if !pendingUploadables.isEmpty {
            uploadResponses.append(response)
        }

        pendingUploadables = Array(pendingUploadables.dropFirst())
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
