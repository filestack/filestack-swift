//
//  PixelateFacesTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/**
    Pixelates selected faces contained inside an image.
 */
@objc(FSPixelateFacesTransform) public class PixelateFacesTransform: Transform, CoverFacesTransformExtension {

    /**
        Initializes a `PixelateFacesTransform` object.
     */
    public init() {
        super.init(name: "pixelate_faces")
    }

    /**
        Adds `amount` option.

        - Parameter value: Valid range: `2...100`
     */
    @discardableResult func amount(_ value: Int = 10) -> Self {
        return appending(key: "amount", value: value)
    }

}
