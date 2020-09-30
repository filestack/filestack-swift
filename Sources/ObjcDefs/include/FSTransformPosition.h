//
//  FSTransformPosition.h
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

@import Foundation;

/// Represents an image transform position type.
typedef NS_OPTIONS(NSUInteger, FSTransformPosition) {

    /// Top
    FSTransformPositionTop = 1 << 0,

    /// Middle
    FSTransformPositionMiddle = 1 << 1,

    /// Bottom
    FSTransformPositionBottom = 1 << 2,

    /// Left
    FSTransformPositionLeft = 1 << 3,

    /// Center
    FSTransformPositionCenter = 1 << 4,

    /// Right
    FSTransformPositionRight = 1 << 5,
};
