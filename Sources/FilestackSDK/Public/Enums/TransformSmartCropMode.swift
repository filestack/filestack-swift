//
//  TransformSmartCropMode.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 16/8/21.
//  Copyright © 2021 Filestack. All rights reserved.
//

import Foundation

/// Represents an image transform smart crop type.
public enum TransformSmartCropMode: CustomStringConvertible {
    /// Face
    case face
    /// Object
    case object(name: String)
    /// Auto
    case auto
}

// MARK: - CustomStringConvertible Conformance

extension TransformSmartCropMode {
    /// Returns a `String` representation of self.
    public var description: String {
        switch self {
        case .face: return "face"
        case .object(let name): return "object,object:\(name)"
        case .auto: return "auto"
        }
    }
}
