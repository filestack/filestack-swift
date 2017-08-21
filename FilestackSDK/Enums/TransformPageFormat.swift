//
//  TransformPageFormat.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/13/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


/**
    Represents an image transform page format type.
 */
@objc(FSTransformPageFormat) public enum TransformPageFormat: UInt, CustomStringConvertible {


    /// Letter
    case letter

    /// Legal
    case legal


    // MARK: - CustomStringConvertible

    /// Returns a `String` representation of self.
    public var description: String {

        switch self {
        case .letter:

            return "letter"

        case .legal:

            return "legal"

        }
    }
}
