//
//  TransformFit.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/12/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/// Represents an image transform fit type.
@objc(FSTransformFit)
public enum TransformFit: UInt, CustomStringConvertible {
    /// Clip
    case clip
    /// Crop
    case crop
    /// Scale
    case scale
    /// Max
    case max
}

// MARK: - CustomStringConvertible Conformance

extension TransformFit {
    /// Returns a `String` representation of self.
    public var description: String {
        switch self {
        case .clip: return "clip"
        case .crop: return "crop"
        case .scale: return "scale"
        case .max: return "max"
        }
    }
}
