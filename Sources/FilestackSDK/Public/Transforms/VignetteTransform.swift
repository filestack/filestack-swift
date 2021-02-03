//
//  VignetteTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import UIKit

/// Applies a vignette border effect to the image.
public class VignetteTransform: Transform {
    // MARK: - Lifecycle

    /// Initializes a `VignetteTransform` object.
    public init() {
        super.init(name: "vignette")
    }
}

// MARK: - Public Functions

public extension VignetteTransform {
    /// Adds the `amount` option.
    ///
    /// - Parameter value: Controls the opacity of the vignette effect. Valid range: `0...100`
    @discardableResult
    func amount(_ value: Int) -> Self {
        return appending(key: "amount", value: value)
    }

    /// Adds the `blurMode` option.
    ///
    /// - Parameter value: An `TransformBlurMode` value.
    @discardableResult
    func blurMode(_ value: TransformBlurMode) -> Self {
        return appending(key: "blurmode", value: value)
    }

    /// Adds the `background` option.
    ///
    /// - Parameter value: Replaces the default transparent background with the specified color.
    @discardableResult
    func background(_ value: UIColor) -> Self {
        return appending(key: "background", value: value.hexString)
    }
}
