//
//  OilPaintTransform.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 14/06/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

/**
 Change the image to look like it was oil painted.
 */
@objc(FSOilPaintTransform) public class OilPaintTransform: Transform {
    /**
     Initializes an `OilPaintTransform` object.
     */
    @objc public init() {
        super.init(name: "oil_paint")
    }

    /**
     Adds `amount` option.

     - Parameter value: Valid range: `2...100`
     */
    @objc @discardableResult public func amount(_ value: Int) -> Self {
        return appending(key: "amount", value: value)
    }
}
