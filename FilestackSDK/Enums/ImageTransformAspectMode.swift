//
//  ImageTransformAspectMode.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/14/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


@objc(FSImageTransformAspectMode) public enum ImageTransformAspectMode: UInt, CustomStringConvertible {

    case preserve

    case constrain

    case letterbox

    case pad

    case crop


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
