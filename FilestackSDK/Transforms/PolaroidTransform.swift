//
//  PolaroidTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/**
 Applies a Polaroid border effect to the image.
 */
@objc(FSPolaroidTransform) public class PolaroidTransform: Transform {
    /**
     Initializes a `PolaroidTransform` object.
     */
    @objc public init() {
        super.init(name: "polaroid")
    }

    /**
     Adds the `color` option.

     - Parameter value: Sets the Polaroid frame color.
     */
    @objc @discardableResult public func color(_ value: UIColor) -> Self {
        return appending(key: "color", value: value.hexString)
    }

    /**
     Adds the `rotate` option.

     - Parameter value: The degree by which to rotate the image clockwise. Valid range: `0...359`
     */
    @objc @discardableResult public func rotate(_ value: Int) -> Self {
        return appending(key: "rotate", value: value)
    }

    /**
     Adds the `background` option.

     - Parameter value: Sets the background color to display behind the Polaroid if
     it has been rotated at all.
     */
    @objc @discardableResult public func background(_ value: UIColor) -> Self {
        return appending(key: "background", value: value.hexString)
    }
}
