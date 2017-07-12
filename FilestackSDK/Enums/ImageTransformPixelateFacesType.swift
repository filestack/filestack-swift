//
//  ImageTransformPixelateFacesType.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/12/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


@objc(FSImageTransformPixelateFacesType) public enum ImageTransformPixelateFacesType: UInt, CustomStringConvertible {

    case rect

    case oval


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
