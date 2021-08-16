//
//  SmartCropTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 16/8/21.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

/// Allows you to programmatically manipulate your images in a way that provides a version of the image that is
/// exactly of the shape you want, while keeping it’s aspect ratio and cutting out least interesting fragments of
/// the input picture.
///
/// For more information, please check our [docs](https://www.filestack.com/docs/api/processing/#smart-crop).
public class SmartCropTransform: Transform {
    // MARK: - Lifecycle

    /// Initializes a `SmartCropTransform` object.
    public init() {
        super.init(name: "smart_crop")
    }
}

// MARK: - Public Functions

public extension SmartCropTransform {
    /// Adds the `mode` option.
    ///
    /// - Parameter value: When `face` value is used, we will run face detection on the input image in order to provide
    /// best results if faces are present. You can specify `object` to crop the image against a particular object,
    /// for example `dog`.
    @discardableResult
    func mode(_ value: TransformSmartCropMode) -> Self {
        return appending(key: "mode", value: value)
    }

    /// Adds the `width` option.
    ///
    /// - Parameter value: Width of the output image.
    @discardableResult
    func width(_ value: Int) -> Self {
        return appending(key: "width", value: value)
    }

    /// Adds the `height` option.
    ///
    /// - Parameter value: Height of the output image.
    @discardableResult
    func height(_ value: Int) -> Self {
        return appending(key: "height", value: value)
    }

    /// Adds the `fillColor` option.
    ///
    /// - Parameter value: Sets the color used for filling the bars that appear when the image is cropped.
    @discardableResult
    func fillColor(_ value: UIColor) -> Self {
        return appending(key: "fill_color", value: value.hexString)
    }

    /// Adds the `coords` option.
    ///
    /// - Parameter value: If true, it returns the coordinates of the cropped area in the image.
    @discardableResult
    func coords(_ value: Bool) -> Self {
        return appending(key: "coords", value: value)
    }
}
