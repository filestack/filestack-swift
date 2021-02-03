//
//  MetadataOptions.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/24/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/// Represents a metadata option.
public struct MetadataOptions: OptionSet {
    /// Size
    static let size = MetadataOptions(rawValue: 1 << 0)

    /// MIME Type
    static let mimeType = MetadataOptions(rawValue: 1 << 1)

    /// Filename
    static let fileName = MetadataOptions(rawValue: 1 << 2)

    /// Width
    static let width = MetadataOptions(rawValue: 1 << 3)

    /// Height
    static let height = MetadataOptions(rawValue: 1 << 4)

    /// Uploaded
    static let uploaded = MetadataOptions(rawValue: 1 << 5)

    /// Writeable
    static let writeable = MetadataOptions(rawValue: 1 << 6)

    /// Cloud
    static let cloud = MetadataOptions(rawValue: 1 << 7)

    /// Source URL
    static let sourceURL = MetadataOptions(rawValue: 1 << 8)

    /// MD5
    static let MD5 = MetadataOptions(rawValue: 1 << 9)

    /// SHA224
    static let SHA224 = MetadataOptions(rawValue: 1 << 10)

    /// SHA256
    static let SHA256 = MetadataOptions(rawValue: 1 << 11)

    /// SHA384
    static let SHA384 = MetadataOptions(rawValue: 1 << 12)

    /// SHA512
    static let SHA512 = MetadataOptions(rawValue: 1 << 13)

    /// Location
    static let location = MetadataOptions(rawValue: 1 << 14)

    /// Path
    static let path = MetadataOptions(rawValue: 1 << 15)

    /// Container
    static let container = MetadataOptions(rawValue: 1 << 16)

    /// Exif
    static let exif = MetadataOptions(rawValue: 1 << 17)

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

// MARK: - Internal Functions

extension MetadataOptions {
    static func all() -> [MetadataOptions] {
        return [
            .size, .mimeType, .fileName, .width, .height, .uploaded, .writeable, .cloud,.sourceURL, .MD5, .SHA224,
            .SHA256, .SHA384, .SHA512, .location, .path, .container, .exif,
        ]
    }

    func toArray() -> [String] {
        let ops: [String] = type(of: self).all().compactMap {
            guard contains($0) else { return nil}

            return $0.stringValue()
        }

        return ops
    }
}

// MARK: - Private Functions

private extension MetadataOptions {
    func stringValue() -> String? {
        switch self {
        case .size: return "size"
        case .mimeType: return "mimetype"
        case .fileName: return "filename"
        case .width: return "width"
        case .height: return "height"
        case .uploaded: return "uploaded"
        case .writeable: return "writeable"
        case .cloud: return "cloud"
        case .sourceURL: return "source_url"
        case .MD5: return "md5"
        case .SHA224: return "sha224"
        case .SHA256: return "sha256"
        case .SHA384: return "sha384"
        case .SHA512: return "sha512"
        case .location: return "location"
        case .path: return "path"
        case .container: return "container"
        case .exif: return "exif"
        default: return nil
        }
    }
}
