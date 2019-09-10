//
//  UploadOptions.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 10/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

/// Represents a set of upload options to pass to `Client` upload functions.
@objc(FSUploadOptions) public class UploadOptions: NSObject {
    /// Attempts to use Intelligent Ingestion when enabled.
    public let preferIntelligentIngestion: Bool

    /// Whether the upload should start immediately.
    public let startImmediately: Bool

    /// An object containing the store options (e.g. location, region, container, access, etc.)
    public let storeOptions: StorageOptions

    /// The chunksize in bytes to use.
    public let chunkSize: Int

    /// How many parts should be uploaded concurrently
    public let partUploadConcurrency: Int

    /// How many chunks should be uploaded concurrently per part
    public let chunkUploadConcurrency: Int

    /// Default initializer.
    public init(preferIntelligentIngestion: Bool,
                startImmediately: Bool,
                storeOptions: StorageOptions,
                chunkSize: Int = UploadOptions.defaultChunkSize,
                partUploadConcurrency: Int = UploadOptions.defaultPartUploadConcurrency,
                chunkUploadConcurrency: Int = UploadOptions.defaultChunkUploadConcurrency) {
        self.preferIntelligentIngestion = preferIntelligentIngestion
        self.startImmediately = startImmediately
        self.storeOptions = storeOptions
        self.chunkSize = chunkSize
        self.partUploadConcurrency = partUploadConcurrency
        self.chunkUploadConcurrency = chunkUploadConcurrency
    }

    /// Default chunk size (5 megabytes)
    public static var defaultChunkSize: Int = 5 * Int(pow(Double(1024), Double(2)))

    /// Default part upload concurrency
    public static var defaultPartUploadConcurrency: Int = 5

    /// Default chunk upload concurrency per part
    public static var defaultChunkUploadConcurrency: Int = 8

    /// A default set of upload options.
    public static var defaults: UploadOptions = {
        UploadOptions(preferIntelligentIngestion: true,
                      startImmediately: true,
                      storeOptions: StorageOptions(location: .s3, access: .private),
                      chunkSize: defaultChunkSize)
    }()
}
