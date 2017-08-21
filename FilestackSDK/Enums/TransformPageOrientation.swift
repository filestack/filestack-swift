//
//  TransformPageOrientation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/13/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


/**
    Represents an image transform page orientation type.
 */
@objc(FSTransformPageOrientation) public enum TransformPageOrientation: UInt, CustomStringConvertible {

    /// Portrait
    case portrait

    /// Landscape
    case landscape


    // MARK: - CustomStringConvertible

    /// Returns a `String` representation of self.
    public var description: String {

        switch self {
        case .portrait:

            return "portrait"

        case .landscape:

            return "landscape"

        }
    }
}
