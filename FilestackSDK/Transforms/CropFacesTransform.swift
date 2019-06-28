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
        return appending(key: "mode", value: value)
    }

    /**
     Adds the `width` option.

     - Parameter value: The crop's width.
     */
    @discardableResult public func width(_ value: Int) -> Self {
        return appending(key: "width", value: value)
    }

    /**
     Adds the `height` option.

     - Parameter value: The crop's height.
     */
    @discardableResult public func height(_ value: Int) -> Self {
        return appending(key: "height", value: value)
    }

    /**
     Adds the `minSize` option.

     - Parameter value: This parameter is used to weed out objects that most likely
     are not faces. Valid range: `0.01...10000`
     */
    @discardableResult public func minSize(_ value: Float) -> Self {
        return appending(key: "minsize", value: value)
    }

    /**
     Adds the `maxSize` option.

     - Parameter value: This parameter is used to weed out objects that most likely
     are not faces. Valid range: `0.01...10000`
     */
    @discardableResult public func maxSize(_ value: Float) -> Self {
        return appending(key: "maxsize", value: value)
    }

    /**
     Adds the `faces` option with value `all`.
     */
    @discardableResult public func allFaces() -> Self {
        return appending(key: "faces", value: "all")
    }

    /**
     Adds the `buffer` option.

     - Parameter value: Adjusts the buffer around the face object as a percentage of
     the original object. Valid range: `0...1000`
     */
    @discardableResult func buffer(_ value: Int) -> Self {
        return appending(key: "buffer", value: value)
    }

    /**
     Adds the `faces` option.

     - Parameter value: The faces to be included in the crop.
     */
    @discardableResult public func faces(_ value: [Int]) -> Self {
        return appending(key: "faces", value: value)
    }
}
