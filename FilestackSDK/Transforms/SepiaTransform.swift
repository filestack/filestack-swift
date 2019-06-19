//
//  SepiaTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/**
    Converts the image to sepia color.
 */
@objc(FSSepiaTransform) public class SepiaTransform: Transform {

    /**
        Initializes a `SepiaTransform` object.
     */
    public init() {
        super.init(name: "sepia")
    }

    /**
        Adds the `tone` option.

        - Parameter value: The value to set the sepia tone to. Valid range: `0...100`
     */
    @discardableResult public func tone(_ value: Int) -> Self {
        return appending(key: "tone", value: value)
    }
}
