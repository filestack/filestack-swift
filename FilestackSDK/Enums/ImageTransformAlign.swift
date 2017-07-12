//
//  ImageTransformAlign.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/12/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


@objc(FSImageTransformAlign) public enum ImageTransformAlign: UInt, CustomStringConvertible {

    case center

    case top

    case bottom

    case left

    case right

    case faces


    /// Returns a `String` representation of self.
    public var description: String {

        switch self {
        case .center:

            return "center"

        case .top:

            return "top"

        case .bottom:

            return "bottom"

        case .left:

            return "left"

        case .right:

            return "right"

        case .faces:

            return "faces"

        }
    }
}
