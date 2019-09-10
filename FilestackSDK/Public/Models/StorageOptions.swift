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
    public let location: StorageLocation

    /// A region name, e.g. "us-east-1".
    public var region: String?

    /// The bucket or container in the specified file store where the file should end up.
    public var container: String?

    /// For S3, this is the key where the file will be stored at. By default, Filestack stores
    /// the file at the root at a unique id, followed by an underscore, followed by the
    /// filename, for example: `3AB239102DB_myvideo.mp4`.
    public var path: String?

    /// The desired filename.
    public var filename: String?

    /// An `StorageAccess` value. Valid options are `.public` or `.private`.
    public var access: StorageAccess?

    /// An array of workflow IDs to trigger for each upload.
    public var workflows: [String]?

    // MARK: - Lifecyle Functions

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
                         access: StorageAccess? = nil,
                         workflows: [String]? = nil) {
        self.location = location
        self.region = region
        self.container = container
        self.path = path
        self.filename = filename
        self.access = access
        self.workflows = workflows

        super.init()
    }
}
