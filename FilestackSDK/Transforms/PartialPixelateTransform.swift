//
//  PartialPixelateTransform.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 14/06/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

/**
 Changes image brightness, saturation and hue.
 */
@objc(FSPartialPixelateTransform) public class PartialPixelateTransform: Transform, PartialCoverTransformExtension {
    /**
     Initializes a `PartialPixelateTransform` object.
     */
    public init(objects: [CGRect]) {
        super.init(name: "partial_pixelate")

        let values = objects.map {
            "[\(Int($0.origin.x)),\(Int($0.origin.y)),\(Int($0.size.width)),\(Int($0.size.height))]"
        }

        appending(key: "objects", value: values)
    }
}
