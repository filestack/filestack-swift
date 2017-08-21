//
//  CropFacesTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


/**
    Crops selected faces contained inside an image.
 */
@objc(FSCropFacesTransform) public class CropFacesTransform: Transform {

    /**
        Initializes a `CropFacesTransform` object.
     */
    public init() {

        super.init(name: "crop_faces")
    }

    /**
        Adds the `mode` option.

        - Parameter value: An `TransformCropMode` value.
     */
    @discardableResult public func mode(_ value: TransformCropMode) -> Self {

        options.append((key: "mode", value: value))

        return self
    }

    /**
        Adds the `width` option.

        - Parameter value: The crop's width.
     */
    @discardableResult public func width(_ value: Int) -> Self {

        options.append((key: "width", value: value))

        return self
    }

    /**
        Adds the `height` option.

        - Parameter value: The crop's height.
     */
    @discardableResult public func height(_ value: Int) -> Self {

        options.append((key: "height", value: value))

        return self
    }

    /**
        Adds the `faces` option with value `all`.
     */
    @discardableResult public func allFaces() -> Self {

        options.append((key: "faces", value: "all"))

        return self
    }

    /**
        Adds the `faces` option.

        - Parameter value: The faces to be included in the crop.
     */
    @discardableResult public func faces(_ value: [Int]) -> Self {

        options.append((key: "faces", value: value))

        return self
    }
}
