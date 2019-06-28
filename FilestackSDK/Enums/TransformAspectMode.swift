//
//  TransformAspectMode.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/14/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/**
 Represents an image transform aspect type.
 */
@objc(FSTransformAspectMode) public enum TransformAspectMode: UInt, CustomStringConvertible {
    /// Preserve
    case preserve

    /// Constrain
    case constrain

    /// Letterbox
    case letterbox

    /// Pad
    case pad

    /// Crop
    case crop

    // MARK: - CustomStringConvertible

    /// Returns a `String` representation of self.
    public var description: String {
        switch self {
        case .preserve:

            return "preserve"

        case .constrain:

            return "constrain"

        case .letterbox:

            return "letterbox"

        case .pad:

            return "pad"

        case .crop:

            return "crop"
        }
    }
}
