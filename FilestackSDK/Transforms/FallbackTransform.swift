//
//  FallbackTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 6/19/19.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

/**
    Returns default file if the source of the transformation does not work or the transformation fails.
 */
@objc(FSFallbackTransform) public class FallbackTransform: Transform {

    /**
        Initializes a `FallbackTransform` object.
     */
    public init() {
        super.init(name: "fallback")
    }

    /**
        Adds the `handle` option.

        - Parameter value: the HANDLE of the file that should be returned.
     */
    @discardableResult public func handle(_ value: String) -> Self {
        return appending(key: "handle", value: value)
    }

    /**
        Adds the `cache` option.

        - Parameter value: The number of seconds fallback response should be cached in CDN.
     */
    @discardableResult public func cache(_ value: Int) -> Self {
        return appending(key: "cache", value: value)
    }
}
