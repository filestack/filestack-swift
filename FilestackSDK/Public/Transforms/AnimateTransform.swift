//
//  AnimateTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 19/08/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

/// Converts a set of images to a GIF file.
@objc(FSAnimateTransform)
public class AnimateTransform: Transform {
    // MARK: - Lifecycle

    /// Initializes an `AnimateTransform` object.
    @objc public init() {
        super.init(name: "animate")
    }
}

// MARK: - Public Functions

public extension AnimateTransform {
    /// Adds the `delay` option.
    ///
    /// - Parameter value: The delay between frames (in milliseconds). Valid range: `1...1000`
    @discardableResult
    @objc func delay(_ value: Int) -> Self {
        return appending(key: "delay", value: value)
    }

    /// Adds the `loop` option.
    ///
    /// - Parameter value: How many times images should be displayed. Use 0 to loop forever.
    @discardableResult
    @objc func loop(_ value: Int) -> Self {
        return appending(key: "loop", value: value)
    }

    /// Adds the `width` option.
    ///
    /// - Parameter value: The new width in pixels. Valid range: `1...10000`
    @discardableResult
    @objc func width(_ value: Int) -> Self {
        return appending(key: "width", value: value)
    }

    /// Adds the `height` option.
    ///
    /// - Parameter value: The new height in pixels. Valid range: `1...10000`
    @discardableResult
    @objc func height(_ value: Int) -> Self {
        return appending(key: "height", value: value)
    }

    /// Adds the `fit` option.
    ///
    /// - Parameter value: A `TransformFit` value.
    @discardableResult
    @objc func fit(_ value: TransformFit) -> Self {
        return appending(key: "fit", value: value)
    }

    /// Adds the `align` option.
    ///
    /// - Parameter value: A `TransformPosition` value.
    @discardableResult
    @objc func align(_ value: TransformPosition) -> Self {
        return appending(key: "align", value: value.toArray())
    }

    /// Adds the `background` option.
    ///
    /// - Parameter value: A color such as `transparent`, `black`, `white`, `red`, etc.
    @discardableResult
    @objc func background(_ value: String) -> Self {
        return appending(key: "background", value: value)
    }
}
