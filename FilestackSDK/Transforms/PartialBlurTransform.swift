//
//  PartialBlurTransform.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 14/06/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

/**
 Changes image brightness, saturation and hue.
 */
@objc(FSPartialBlurTransform) public class PartialBlurTransform: Transform, PartialCoverTransformExtension {
    /**
     Initializes a `PartialBlurTransform` object.
     */
    public init(objects: [CGRect]) {
        super.init(name: "partial_blur")

        let values = objects.map {
            "[\(Int($0.origin.x)),\(Int($0.origin.y)),\(Int($0.size.width)),\(Int($0.size.height))]"
        }

        appending(key: "objects", value: values)
    }
}
