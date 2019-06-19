//
//  WatermarkTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/**
    Watermarks the image by overlaying another image on top of your main image.
 */
@objc(FSWatermarkTransform) public class WatermarkTransform: Transform {

    /**
        Initializes a `WatermarkTransform` object.

        - Parameter file: The Filestack handle of the image that you want to layer on top of another image as a watermark.
     */
    public init(file: String) {
        super.init(name: "watermark")
        options.append((key: "file", value: file))
    }

    /**
        Adds the `size` option.

        - Parameter value: The size of the overlayed image as a percentage of its original size.
        Valid range: `1...500`
     */
    @discardableResult public func size(_ value: Int) -> Self {
        return appending(key: "size", value: value)
    }

    /**
        Adds the `position` option.

        - Parameter value: The position of the overlayed image. These values can be paired as well like position: [.top, .right].
     */
    @discardableResult public func position(_ value: TransformPosition) -> Self {
        return appending(key: "position", value: value.toArray())
    }
}
