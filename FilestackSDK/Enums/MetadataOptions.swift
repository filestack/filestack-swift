//
//  MetadataOptions.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/24/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


/**
    Represents a metadata option.
 */
@objc(FSMetadataOptions) public enum MetadataOptions: UInt, CustomStringConvertible {

    case size

    case mimeType

    case fileName

    case width

    case height

    case uploaded

    case writeable

    case cloud

    case sourceURL

    case md5

    case sha224

    case sha256

    case sha384

    case sha512

    case location

    case path

    case container

    case exif


    /// Returns a `String` representation of self.
    public var description: String {

        switch self {
        case .size:

            return "size"

        case .mimeType:

            return "mimetype"

        case .fileName:

            return "filename"

        case .width:

            return "width"

        case .height:

            return "height"

        case .uploaded:

            return "uploaded"

        case .writeable:

            return "writeable"

        case .cloud:

            return "cloud"

        case .sourceURL:

            return "source_url"

        case .md5:

            return "md5"

        case .sha224:

            return "sha224"

        case .sha256:

            return "sha256"

        case .sha384:

            return "sha384"

        case .sha512:

            return "sha512"

        case .location:

            return "location"

        case .path:

            return "path"

        case .container:

            return "container"

        case .exif:

            return "exif"

        }
    }
}
