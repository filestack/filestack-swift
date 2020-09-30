//
//  FSMetadataOptions.h
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Represents a metadata option.
typedef NS_OPTIONS(NSUInteger, FSMetadataOptions) {

    /// Size
    FSMetadataSize = 1 << 0,

    /// MIME Type
    FSMetadataMimeType = 1 << 1,

    /// Filename
    FSMetadataFileName = 1 << 2,

    /// Width
    FSMetadataWidth = 1 << 3,

    /// Height
    FSMetadataHeight = 1 << 4,

    /// Uploaded
    FSMetadataUploaded = 1 << 5,

    /// Writeable
    FSMetadataWriteable = 1 << 6,

    /// Cloud
    FSMetadataCloud = 1 << 7,

    /// Source URL
    FSMetadataSourceURL = 1 << 8,

    /// MD5
    FSMetadataMD5 = 1 << 9,

    /// SHA224
    FSMetadataSHA224 = 1 << 10,

    /// SHA256
    FSMetadataSHA256 = 1 << 11,

    /// SHA384
    FSMetadataSHA384 = 1 << 12,

    /// SHA512
    FSMetadataSHA512 = 1 << 13,

    /// Location
    FSMetadataLocation = 1 << 14,

    /// Path
    FSMetadataPath = 1 << 15,

    /// Container
    FSMetadataContainer = 1 << 16,
        
    /// Exif
    FSMetadataExif = 1 << 17,
};
