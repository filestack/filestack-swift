//
//  ImageTransformCropMode.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/12/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


/**
    Represents an image transform crop type.
 */
@objc(FSImageTransformCropMode) public enum ImageTransformCropMode: UInt, CustomStringConvertible {


    /// Thumb
    case thumb

    /// Crop
    case crop

    /// Fill
    case fill


    // MARK: - CustomStringConvertible

    /// Returns a `String` representation of self.
    public var description: String {

        switch self {
        case .thumb:

            return "thumb"

        case .crop:

            return "crop"

        case .fill:

            return "fill"

        }
    }
}
