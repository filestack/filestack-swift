//
//  StorageLocation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 03/07/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


/**
    Represents a type of cloud storage location.

    See [CloudStorage](https://www.filestack.com/docs/cloud-storage/) for more information 
    about cloud storage locations.
 */
@objc(FSStorageLocation) public enum StorageLocation: UInt, CustomStringConvertible {

    case s3

    case dropbox

    case rackspace

    case azure

    case gcs

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
