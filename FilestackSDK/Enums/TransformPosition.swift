//
//  TransformPosition.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/12/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


/**
    Represents an image transform position type.
 */
public typealias TransformPosition = FSTransformPosition


public extension TransformPosition {

    internal static func all() -> [TransformPosition] {

        return [.top, .middle, .bottom, .left, .center, .right]
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
        case TransformPosition.top:

            return "top"

        case TransformPosition.middle:

            return "middle"

        case TransformPosition.bottom:

            return "bottom"

        case TransformPosition.left:

            return "left"

        case TransformPosition.center:

            return "center"

        case TransformPosition.right:

            return "right"

        default:
            
            return nil
        }
    }
}
