//
//  TransformBlurMode.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/13/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/**
 Represents an image transform blur type.
 */
@objc(FSTransformBlurMode) public enum TransformBlurMode: UInt, CustomStringConvertible {
    /// Linear
    case linear

    /// Gaussian
    case gaussian

    // MARK: - CustomStringConvertible

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
