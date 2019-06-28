//
//  TransformStyleMode.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 15/06/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

/**
 Represents an image transform style type.
 */
@objc(FSTransformStyleMode) public enum TransformStyleMode: UInt, CustomStringConvertible {
    /// Artwork
    case artwork

    /// Photo
    case photo

    // MARK: - CustomStringConvertible

    /// Returns a `String` representation of self.
    public var description: String {
        switch self {
        case .artwork: return "artwork"
        case .photo: return "photo"
        }
    }
}
