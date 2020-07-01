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
        UploadOptions(preferIntelligentIngestion: true, startImmediately: true)
    }()

    // MARK: - Public Properties

    /// Attempts to use Intelligent Ingestion when enabled.
    @objc public var preferIntelligentIngestion: Bool

    /// Whether the upload should start immediately.
    @objc public var startImmediately: Bool

    /// An object containing the store options (e.g. location, region, container, access, etc.)
    @objc public var storeOptions: StorageOptions

    /// How many parts should be uploaded concurrently
    @objc public var partUploadConcurrency: Int

    /// How many chunks should be uploaded concurrently per part
    @objc public var chunkUploadConcurrency: Int

    // MARK: - Lifecycle

    /// Default initializer.
    @objc public init(preferIntelligentIngestion: Bool,
                      startImmediately: Bool,
                      storeOptions: StorageOptions = .defaults,
                      partUploadConcurrency: Int = UploadOptions.defaultPartUploadConcurrency,
                      chunkUploadConcurrency: Int = UploadOptions.defaultChunkUploadConcurrency) {
        self.preferIntelligentIngestion = preferIntelligentIngestion
        self.startImmediately = startImmediately
        self.storeOptions = storeOptions
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
