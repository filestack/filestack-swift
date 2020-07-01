//
//  BlurTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/// Applies a blurring effect to the image.
@objc(FSBlurTransform)
public class BlurTransform: Transform {
    // MARK: - Lifecycle

    /// Initializes a `BlurTransform` object.
    @objc public init() {
        super.init(name: "blur")
    }
}

// MARK: - Public Functions

public extension BlurTransform {
    /// Adds the `amount` option.
    ///
    /// - Parameter value: The amount to blur the image. Valid range: `1...20`
    @discardableResult
    @objc func amount(_ value: Int) -> Self {
        return appending(key: "amount", value: value)
    }
}
