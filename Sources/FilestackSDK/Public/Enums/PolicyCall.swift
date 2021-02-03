//
//  PolicyCall.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/12/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/// Represents a policy call type.
///
/// See [Creating Policies](https://www.filestack.com/docs/security/creating-policies) for more
/// information about policy calls.
public struct PolicyCall: OptionSet {
    /// Allows users to upload files.
    static let pick = PolicyCall(rawValue: 1 << 0)

    /// Allows files to be viewed/accessed.
    static let read = PolicyCall(rawValue: 1 << 1)

    /// Allows metadata about files to be retrieved.
    static let stat = PolicyCall(rawValue: 1 << 2)

    /// Allows use of the write function.
    static let write = PolicyCall(rawValue: 1 << 3)

    /// Allows use of the writeUrl function.
    static let writeURL = PolicyCall(rawValue: 1 << 4)

    /// Allows files to be written to custom storage.
    static let store = PolicyCall(rawValue: 1 << 5)

    /// Allows transformation (crop, resize, rotate) of files, also needed for the viewer.
    static let convert = PolicyCall(rawValue: 1 << 6)

    /// Allows removal of Filestack files.
    static let remove = PolicyCall(rawValue: 1 << 7)

    /// Allows exif metadata to be accessed.
    static let exif = PolicyCall(rawValue: 1 << 8)

    /// Allows workflows to be run.
    static let runWorkflow = PolicyCall(rawValue: 1 << 9)

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

// MARK: - Internal Functions

extension PolicyCall {
    static func all() -> [PolicyCall] {
        return [.pick, .read, .stat, .write, .writeURL, .store, .convert, .remove, .exif, .runWorkflow]
    }

    func toArray() -> [String] {
        let ops: [String] = type(of: self).all().compactMap {
            guard contains($0) else {
                return nil
            }
            return $0.stringValue()
        }

        return ops
    }
}

// MARK: - Private Functions

private extension PolicyCall {
    func stringValue() -> String? {
        switch self {
        case .pick: return "pick"
        case .read: return "read"
        case .stat: return "stat"
        case .write: return "write"
        case .writeURL: return "write_url"
        case .store: return "store"
        case .convert: return "convert"
        case .remove: return "remove"
        case .exif: return "exif"
        case .runWorkflow: return "runWorkflow"
        default: return nil
        }
    }
}
