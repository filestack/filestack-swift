//
//  ImageTransformPosition.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/12/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


/**
    Represents an image transform position type.
 */
@objc(FSImageTransformPosition) public enum ImageTransformPosition: UInt, CustomStringConvertible {

    /// Top
    case top

    /// Middle
    case middle

    /// Bottom
    case bottom

    /// Left
    case left

    /// Center
    case center

    /// Right
    case right


    // MARK: - CustomStringConvertible

    /// Returns a `String` representation of self.
    public var description: String {

        switch self {
        case .top:

            return "top"

        case .middle:

            return "middle"

        case .bottom:

            return "bottom"

        case .left:

            return "left"

        case .center:

            return "center"

        case .right:

            return "right"

        }
    }
}
