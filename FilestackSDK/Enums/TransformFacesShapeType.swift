//
//  TransformPixelateFacesType.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/12/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


/**
    Represents an image transform pixelate faces type.
 */
@objc(FSTransformPixelateFacesType) public enum TransformFacesShapeType: UInt, CustomStringConvertible {

    /// Rect
    case rect

    /// Oval
    case oval


    // MARK: - CustomStringConvertible

    /// Returns a `String` representation of self.
    public var description: String {

        switch self {
        case .rect:

            return "rect"

        case .oval:

            return "oval"

        }
    }
}
