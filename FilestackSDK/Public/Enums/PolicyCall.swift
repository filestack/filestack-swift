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
public typealias PolicyCall = FSPolicyCall

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
        case PolicyCall.pick:

            return "pick"

        case PolicyCall.read:

            return "read"

        case PolicyCall.stat:

            return "stat"

        case PolicyCall.write:

            return "write"

        case PolicyCall.writeURL:

            return "write_url"

        case PolicyCall.store:

            return "store"

        case PolicyCall.convert:

            return "convert"

        case PolicyCall.remove:

            return "remove"

        case PolicyCall.exif:

            return "exif"

        case PolicyCall.runWorkflow:

            return "runWorkflow"

        default:

            return nil
        }
    }
}
