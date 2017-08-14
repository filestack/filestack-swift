//
//  PolicyCall.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/12/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


/**
    Represents a policy call type.

    See [Creating Policies](https://www.filestack.com/docs/security/creating-policies) for more
    information about policy calls.
 */
@objc(FSPolicyCall) public enum PolicyCall: UInt, CustomStringConvertible {

    /// Allows users to upload files.
    case pick

    /// Allows files to be viewed/accessed.
    case read

    /// Allows metadata about files to be retrieved.
    case stat

    /// Allows use of the write function.
    case write

    /// Allows use of the writeUrl function.
    case writeURL

    /// Allows files to be written to custom storage.
    case store

    /// Allows transformation (crop, resize, rotate) of files, also needed for the viewer.
    case convert

    /// Allows removal of Filestack files.
    case remove

    /// Allows exif metadata to be accessed.
    case exif


    // MARK: - CustomStringConvertible

    /// Returns a `String` representation of self.
    public var description: String {

        switch self {
        case .pick:

            return "pick"

        case .read:

            return "read"

        case .stat:

            return "stat"

        case .write:

            return "write"

        case .writeURL:

            return "write_url"

        case .store:

            return "store"

        case .convert:

            return "convert"

        case .remove:

            return "remove"

        case .exif:

            return "exif"
        }
    }
}
