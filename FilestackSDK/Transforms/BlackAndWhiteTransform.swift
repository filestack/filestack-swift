//
//  BlackAndWhiteTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/**
    Converts the image to black and white.
 */
@objc(FSBlackAndWhiteTransform) public class BlackAndWhiteTransform: Transform {

    /**
        Initializes a `BlackAndWhiteTransform` object.
     */
    public init() {
        super.init(name: "blackwhite")
    }

    /**
        Adds the `threshold` option.

        - Parameter value: Controls the balance between black and white (contrast) in
        the returned image. Valid range: `1...100`
     */
    @discardableResult public func threshold(_ value: Int) -> Self {
        return appending(key: "threshold", value: value)
    }
}
