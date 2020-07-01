//
//  UpscaleTransform.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 15/06/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

/// Upscales the image making it two times bigger.
@objc(FSUpscaleTransform)
public class UpscaleTransform: Transform {
    // MARK: - Lifecycle

    /// Initializes an `UpscaleTransform` object.
    @objc public init() {
        super.init(name: "upscale")
    }
}

// MARK: - Public Functions

public extension UpscaleTransform {
    /// Turns off resizing of image.
    @discardableResult
    @objc func noUpscale() -> Self {
        return appending(key: "upscale", value: false)
    }

    /// Adds the `noise` option.
    ///
    /// - Parameter value: An `TransformNoiseMode` value.
    @discardableResult
    @objc func noise(_ value: TransformNoiseMode) -> Self {
        return appending(key: "noise", value: value)
    }

    /// Adds the `style` option.
    ///
    /// - Parameter value: An `TransformStyleMode` value.
    @discardableResult
    @objc func style(_ value: TransformStyleMode) -> Self {
        return appending(key: "style", value: value)
    }
}
