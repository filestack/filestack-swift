//
//  MultifileUpload.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 14/05/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

/// :nodoc:
@objc(FSMultifileUpload) public class MultifileUpload: NSObject {
    // MARK: - Public Properties

    /// The overall upload progress.
    @objc public lazy var progress: Progress = {
        Progress(totalUnitCount: Int64(totalSize))
    }()

    /// Current upload status.
    @objc public private(set) var currentStatus: UploadStatus = .notStarted

    // MARK: - Internal Properties

    public var uploadProgress: ((Progress) -> Void)?
    public var completionHandler: (([NetworkJSONResponse]) -> Void)?

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
    /// You should use this only before your upload starts.
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
    /// Please notice that any already uploaded files **will not** be deleted —
    /// only the current file being uploaded (if any) and any pending files will be affected.
    ///
    /// This will trigger `completionHandler`.
    @objc
    @discardableResult public func cancel() -> Bool {
        switch currentStatus {
        case .inProgress:
            shouldAbort = true
            currentOperation?.cancel()
            stopUpload()

            return true
        default:
            return false
        }
    }

    /// Starts upload.
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
        currentStatus = .inProgress

        guard shouldAbort == false, let nextUploadable = pendingUploadables.first, let size = nextUploadable.size else {
            stopUpload()
            return
        }

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
        if progress.completedUnitCount == progress.totalUnitCount {
            currentStatus = .completed
        } else {
            currentStatus = .cancelled
        }

        while uploadResponses.count < pendingUploadables.count {
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

    func updateProgress(_ currentFileProgress: Progress) {
        currentFileSize = currentFileProgress.completedUnitCount
        progress.completedUnitCount = finishedFilesSize + currentFileSize

        queue.async {
            self.uploadProgress?(self.progress)
        }
    }

    func finishedCurrentFile(with response: NetworkJSONResponse) {
        finishedFilesSize += currentFileSize
        uploadResponses.append(response)
        pendingUploadables = Array(pendingUploadables.dropFirst())
        uploadNextFile()
    }
}
