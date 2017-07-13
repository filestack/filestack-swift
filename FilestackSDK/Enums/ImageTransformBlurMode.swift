//
//  ImageTransformBlurMode.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/13/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


@objc(FSImageTransformBlurMode) public enum ImageTransformBlurMode: UInt, CustomStringConvertible {

    case linear

    case gaussian


    /// Returns a `String` representation of self.
    public var description: String {

        switch self {
        case .linear:

            return "linear"

        case .gaussian:

            return "gaussian"

        }
    }
}
