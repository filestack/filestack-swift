//
//  ImageTransformPosition.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/12/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


@objc(FSImageTransformPosition) public enum ImageTransformPosition: UInt, CustomStringConvertible {

    case top

    case middle

    case bottom

    case left

    case center

    case right

    
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
