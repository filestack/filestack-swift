//
//  ImageTransformPageFormat.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/13/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


@objc(FSImageTransformPageFormat) public enum ImageTransformPageFormat: UInt, CustomStringConvertible {

    case letter

    case legal


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
