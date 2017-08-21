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
public typealias MetadataOptions = FSMetadataOptions

public extension MetadataOptions {

    internal static func all() -> [MetadataOptions] {

        return [
            .size, .mimeType, .fileName, .width, .height, .uploaded, .writeable, .cloud,
            .sourceURL, .MD5, .SHA224, .SHA256, .SHA384, .SHA512, .location, .path,
            .container, .exif
        ]
    }

    internal func toArray() -> [String] {

        let ops: [String] = type(of: self).all().flatMap {
            if contains($0) {
                return $0.stringValue()
            } else {
                return nil
            }
        }

        return ops
    }

    private func stringValue() -> String? {

        switch self {
        case MetadataOptions.size:

            return "size"

        case MetadataOptions.mimeType:

            return "mimetype"

        case MetadataOptions.fileName:

            return "filename"

        case MetadataOptions.width:

            return "width"

        case MetadataOptions.height:

            return "height"

        case MetadataOptions.uploaded:

            return "uploaded"

        case MetadataOptions.writeable:

            return "writeable"

        case MetadataOptions.cloud:

            return "cloud"

        case MetadataOptions.sourceURL:

            return "source_url"

        case MetadataOptions.MD5:

            return "md5"

        case MetadataOptions.SHA224:

            return "sha224"

        case MetadataOptions.SHA256:

            return "sha256"

        case MetadataOptions.SHA384:

            return "sha384"

        case MetadataOptions.SHA512:

            return "sha512"

        case MetadataOptions.location:

            return "location"

        case MetadataOptions.path:

            return "path"

        case MetadataOptions.container:

            return "container"

        case MetadataOptions.exif:

            return "exif"

        default:

            return nil
        }
    }
}
