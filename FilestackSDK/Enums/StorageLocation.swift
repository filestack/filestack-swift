//
//  StorageLocation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 03/07/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


/**
    Represents a cloud storage location type.

    See [CloudStorage](https://www.filestack.com/docs/cloud-storage/) for more information 
    about cloud storage locations.
 */
@objc(FSStorageLocation) public enum StorageLocation: UInt, CustomStringConvertible {

    /// Amazon S3
    case s3

    /// Dropbox
    case dropbox

    /// Rackspace
    case rackspace

    /// Azure
    case azure

    /// Google Cloud Storage
    case gcs

    
    // MARK: - CustomStringConvertible

    /// Returns a `String` representation of self.
    public var description: String {

        switch self {
        case .s3:

            return "S3"

        case .dropbox:

            return "dropbox"

        case .rackspace:

            return "rackspace"

        case .azure:

            return "azure"

        case .gcs:

            return "gcs"

        }
    }
}
