//
//  PixelateTransform.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 14/06/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

/**
    Pixelates the image.
 */
@objc(FSPixelateTransform) public class PixelateTransform: Transform {

    /**
        Initializes a `PixelateTransform` object.
     */
    public init() {
        super.init(name: "pixelate")
    }

    /**
        Adds `amount` option.

        - Parameter value: Valid range: `2...100`
     */
    @discardableResult public func amount(_ value: Int = 2) -> Self {
        return appending(key: "amount", value: value)
    }
}
