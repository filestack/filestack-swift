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

    /// Size
    case size

    /// MIME type
    case mimeType

    /// Filename
    case fileName

    /// Width
    case width

    /// Height
    case height

    /// Uploaded
    case uploaded

    /// Writeable
    case writeable

    /// Cloud
    case cloud

    /// Source URL
    case sourceURL

    /// MD5
    case md5

    /// SHA224
    case sha224

    /// SHA256
    case sha256

    /// SHA384
    case sha384

    /// SHA512
    case sha512

    /// Location
    case location

    /// Path
    case path

    /// Container
    case container

    /// Exif
    case exif


    // MARK: - CustomStringConvertible
    
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
