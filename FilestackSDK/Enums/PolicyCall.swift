//
//  PolicyCall.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/12/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


/**
    Represents a policy call type.

    See [Creating Policies](https://www.filestack.com/docs/security/creating-policies) for more
    information about policy calls.
 */
public typealias PolicyCall = FSPolicyCall

public extension PolicyCall {

    internal static func all() -> [PolicyCall] {

        return [.pick, .read, .stat, .write, .writeURL, .store, .convert, .remove, .exif]
    }

    internal func toArray() -> [String] {

        let ops: [String] = type(of: self).all().flatMap {
            if contains($0) {
                return $0.stringValue()
            } else {
                return nil
            }
        }

        return ops
    }

    private func stringValue() -> String? {

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

        default:

            return nil
        }
    }
}
