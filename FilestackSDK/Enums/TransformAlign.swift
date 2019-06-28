//
//  TransformAlign.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/12/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/**
 Represents an image transform alignment type.
 */
@objc(FSTransformAlign) public enum TransformAlign: UInt, CustomStringConvertible {
    /// Center
    case center

    /// Top
    case top

    /// Bottom
    case bottom

    /// Left
    case left

    /// Right
    case right

    /// Faces
    case faces

    // MARK: - CustomStringConvertible

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
