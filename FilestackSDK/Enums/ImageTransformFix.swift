//
//  ImageTransformFix.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/12/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


@objc(FSImageTransformFit) public enum ImageTransformFit: UInt, CustomStringConvertible {

    case clip

    case crop

    case scale

    case max

    
    /// Returns a `String` representation of self.
    public var description: String {

        switch self {
        case .clip:

            return "clip"

        case .crop:

            return "crop"

        case .scale:

            return "scale"

        case .max:

            return "max"
        }
    }
}
