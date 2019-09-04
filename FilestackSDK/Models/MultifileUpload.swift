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

    /// Array of local URLs of files we want to upload.
    @objc public var uploadURLs: [URL] {
        didSet {
            leftToUploadURLs = uploadURLs
        }
    }

    // MARK: - Private Properties

    private var leftToUploadURLs: [URL] = []
    private var uploadResponses: [NetworkJSONResponse] = []

    private var finishedFilesSize: Int64
    private var currentFileSize: Int64
    private var progress: Progress {
        let progress = Progress(totalUnitCount: totalSize())
        progress.completedUnitCount = finishedFilesSize + currentFileSize
        return progress
    }

    private var shouldAbort: Bool
    private var useIntelligentIngestionIfAvailable: Bool
    private var currentOperation: MultipartUpload?

    private let queue: DispatchQueue
    private var uploadProgress: ((Progress) -> Void)?
    private var completionHandler: (([NetworkJSONResponse]) -> Void)?
    private let apiKey: String
    private let storeOptions: StorageOptions
    private let security: Security?

    init(with uploadURLs: [URL]?,
         queue: DispatchQueue = .main,
         uploadProgress: ((Progress) -> Void)? = nil,
         completionHandler: @escaping ([NetworkJSONResponse]) -> Void,
         apiKey: String,
         storeOptions: StorageOptions,
         security: Security? = nil,
         useIntelligentIngestionIfAvailable: Bool = true) {
        let urls = uploadURLs ?? []
        self.shouldAbort = false
        self.uploadURLs = urls
        self.leftToUploadURLs = urls
        self.queue = queue
        self.uploadProgress = uploadProgress
        self.completionHandler = completionHandler
        self.apiKey = apiKey
        self.storeOptions = storeOptions
        self.security = security
        self.useIntelligentIngestionIfAvailable = useIntelligentIngestionIfAvailable
        self.finishedFilesSize = 0
        self.currentFileSize = 0
    }

    // MARK: - Public Functions

    /**
     Cancels multifile upload request. Canceling won't delete already uploaded files - only cancel current upload and upload of all files not uploaded yet. This will trigger completionHandler.
     */
    @objc public func cancel() {
        shouldAbort = true
        currentOperation?.cancel()
        stopUpload()
    }

    /**
     Start uploading files.
     */
    @objc public func uploadFiles() {
        uploadNextFile()
        showMinimalProgress()
    }
}

private extension MultifileUpload {
    func showMinimalProgress() {
        let minimalProgress = Progress(totalUnitCount: 100)
        minimalProgress.completedUnitCount = 1
        updateProgress(minimalProgress)
    }

    func totalSize() -> Int64 {
        return Int64(uploadURLs.reduce(UInt64(0)) { sum, url in sum + (url.size() ?? 0) })
    }

    func uploadNextFile() {
        guard
            shouldAbort == false,
            let nextURL = leftToUploadURLs.first else {
            stopUpload()
            return
        }
        currentFileSize = Int64(nextURL.size() ?? 0)
        currentOperation = MultipartUpload(at: nextURL,
                                           queue: queue,
                                           uploadProgress: { progress in self.updateProgress(progress) },
                                           completionHandler: { response in self.finishedCurrentFile(with: response) },
                                           partUploadConcurrency: 5,
                                           chunkUploadConcurrency: 8,
                                           apiKey: apiKey,
                                           storeOptions: storeOptions,
                                           security: security,
                                           useIntelligentIngestionIfAvailable: useIntelligentIngestionIfAvailable)
        currentOperation?.uploadFile()
    }

    func stopUpload() {
        while uploadResponses.count < uploadURLs.count {
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
        queue.async { self.uploadProgress?(self.progress) }
    }

    func finishedCurrentFile(with response: NetworkJSONResponse) {
        finishedFilesSize += currentFileSize
        uploadResponses.append(response)
        leftToUploadURLs = Array(leftToUploadURLs.dropFirst())
        uploadNextFile()
    }
}
