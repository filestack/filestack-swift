//
//  FlipTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/**
 Flips/mirrors the image vertically.
 */
@objc(FSFlipTransform) public class FlipTransform: Transform {
    /**
     Initializes a `FlipTransform` object.
     */
    @objc public init() {
        super.init(name: "flip")
    }
}
