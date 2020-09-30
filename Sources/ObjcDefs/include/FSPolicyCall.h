//
//  FSPolicyCall.h
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

@import Foundation;

/// Represents a policy call type.
///
/// See [Creating Policies](https://www.filestack.com/docs/security/creating-policies) for more information about policy
/// calls.
typedef NS_OPTIONS(NSUInteger, FSPolicyCall) {

    /// Allows users to upload files.
    FSPolicyCallPick = 1 << 0,

    /// Allows files to be viewed/accessed.
    FSPolicyCallRead = 1 << 1,

    /// Allows metadata about files to be retrieved.
    FSPolicyCallStat = 1 << 2,

    /// Allows use of the write function.
    FSPolicyCallWrite = 1 << 3,

    /// Allows use of the writeUrl function.
    FSPolicyCallWriteURL = 1 << 4,

    /// Allows files to be written to custom storage.
    FSPolicyCallStore = 1 << 5,

    /// Allows transformation (crop, resize, rotate) of files, also needed for the viewer.
    FSPolicyCallConvert = 1 << 6,

    /// Allows removal of Filestack files.
    FSPolicyCallRemove = 1 << 7,

    /// Allows exif metadata to be accessed.
    FSPolicyCallExif = 1 << 8,

    /// Allows workflows to be run.
    FSPolicyCallRunWorkflow = 1 << 9,
};
