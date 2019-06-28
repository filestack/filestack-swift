//
//  CircleTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/**
 Applies a circle border effect to the image.
 */
@objc(FSCircleTransform) public class CircleTransform: Transform {
    /**
     Initializes a `CircleTransform` object.
     */
    public init() {
        super.init(name: "circle")
    }

    /**
     Adds the `background` option.

     - Parameter value: Sets the background color to display behind the image.
     */
    @discardableResult public func background(_ value: UIColor) -> Self {
        return appending(key: "background", value: value.hexString)
    }
}
