//
//  UploadOptions.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 10/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

/// Represents a set of options for uploading items to a given storage location.
@objc(FSUploadOptions)
public class UploadOptions: NSObject {
    // MARK: - Public Static Properties

    /// Default part upload concurrency
    @objc public static var defaultPartUploadConcurrency: Int = 5

    /// Default chunk upload concurrency per part
    @objc public static var defaultChunkUploadConcurrency: Int = 8

    /// A default set of upload options.
    @objc public static var defaults: UploadOptions = {
        UploadOptions(
            preferIntelligentIngestion: true,
            startImmediately: true,
            deleteTemporaryFilesAfterUpload: false
        )
    }()

    // MARK: - Public Properties

    /// Attempts to use Intelligent Ingestion when enabled.
    @objc public var preferIntelligentIngestion: Bool

    /// Whether the upload should start immediately.
    @objc public var startImmediately: Bool

    /// Whether uploaded files located in the user's temporary directoy should be deleted after being uploaded.
    @objc public var deleteTemporaryFilesAfterUpload: Bool

    /// An object containing the store options (e.g. location, region, container, access, etc.)
    @objc public var storeOptions: StorageOptions

    /// A dictionary containing any custom data (tags) that should be associated to this upload.
    /// For more information, please check [Upload tags](https://www.filestack.com/docs/uploads/uploading/#upload-tags).
    @objc public var uploadTags: [String: String]

    /// How many parts should be uploaded concurrently
    @objc public var partUploadConcurrency: Int

    /// How many chunks should be uploaded concurrently per part
    @objc public var chunkUploadConcurrency: Int

    // MARK: - Lifecycle

    /// Default initializer.
    @objc public init(preferIntelligentIngestion: Bool,
                      startImmediately: Bool,
                      deleteTemporaryFilesAfterUpload: Bool,
                      storeOptions: StorageOptions = .defaults,
                      uploadTags: [String: String] = [:],
                      partUploadConcurrency: Int = UploadOptions.defaultPartUploadConcurrency,
                      chunkUploadConcurrency: Int = UploadOptions.defaultChunkUploadConcurrency) {
        self.preferIntelligentIngestion = preferIntelligentIngestion
        self.startImmediately = startImmediately
        self.deleteTemporaryFilesAfterUpload = deleteTemporaryFilesAfterUpload
        self.storeOptions = storeOptions
        self.uploadTags = uploadTags
        self.partUploadConcurrency = partUploadConcurrency
        self.chunkUploadConcurrency = chunkUploadConcurrency
    }
}

// MARK: - CustomStringConvertible Conformance

extension UploadOptions {
    /// :nodoc:
    override public var description: String {
        return Tools.describe(subject: self)
    }
}
