//
//  StorageOptions.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 10/30/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/**
 Represents a set of storage options.
 */
@objc(FSStorageOptions) public class StorageOptions: NSObject {
    // MARK: - Public Properties

    /// An `StorageLocation` value. Valid options are `.s3`, `.dropbox`, `.rackspace`, `.azure`, `.gcs`.
    @objc public let location: StorageLocation

    /// A region name, e.g. "us-east-1".
    @objc public var region: String?

    /// The bucket or container in the specified file store where the file should end up.
    @objc public var container: String?

    /// For S3, this is the key where the file will be stored at. By default, Filestack stores
    /// the file at the root at a unique id, followed by an underscore, followed by the
    /// filename, for example: `3AB239102DB_myvideo.mp4`.
    @objc public var path: String?

    /// The desired filename.
    @objc public var filename: String?

    /// The file's MIME type.
    @objc public var mimeType: String?

    /// An `StorageAccess` value. Valid options are `.public` or `.private`.
    public var access: StorageAccess?

    /// An array of workflow IDs to trigger for each upload.
    @objc public var workflows: [String]?

    // MARK: - Lifecycle Functions

    /// Convenience initializer (for Objective-C).
    @objc public convenience init(location: StorageLocation) {
        self.init(location: location, region: nil, container: nil, path: nil, filename: nil, access: nil)
    }

    /// Convenience initializer (for Objective-C).
    @objc public convenience init(location: StorageLocation, access: StorageAccess) {
        self.init(location: location, region: nil, container: nil, path: nil, filename: nil, access: access)
    }

    /// Default initializer.
    @nonobjc public init(location: StorageLocation,
                         region: String? = nil,
                         container: String? = nil,
                         path: String? = nil,
                         filename: String? = nil,
                         mimeType: String? = nil,
                         access: StorageAccess? = nil,
                         workflows: [String]? = nil) {
        self.location = location
        self.region = region
        self.container = container
        self.path = path
        self.filename = filename
        self.mimeType = mimeType
        self.access = access
        self.workflows = workflows

        super.init()
    }

    /// A default set of storage options.
    @objc public static var defaults: StorageOptions = {
        StorageOptions(location: .s3, access: .private)
    }()
}

// MARK: - CustomStringConvertible

extension StorageOptions {
    /// :nodoc:
    override public var description: String {
        return Tools.describe(subject: self)
    }
}
