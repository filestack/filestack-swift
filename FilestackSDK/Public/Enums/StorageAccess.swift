//
//  StorageAccess.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/14/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/// Represents the storage access to a file.
@objc(FSStorageAccess)
public enum StorageAccess: UInt, CustomStringConvertible {
    /// Private storage access.
    case `private`
    /// Public storage access.
    case `public`
}

// MARK: - CustomStringConvertible Conformance

extension StorageAccess {
    /// Returns a `String` representation of self.
    public var description: String {
        switch self {
        case .private: return "private"
        case .public: return "public"
        }
    }
}
