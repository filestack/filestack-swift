//
//  RoundedCornersTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import UIKit

/// Rounds the image's corners.
public class RoundedCornersTransform: Transform {
    // MARK: - Lifecycle

    /// Initializes a `RoundedCornersTransform` object.
    public init() {
        super.init(name: "rounded_corners")
    }
}

// MARK: - Public Functions

public extension RoundedCornersTransform {
    /// Adds the `radius` option with value set to "max".
    @discardableResult
    func maxRadius() -> Self {
        return appending(key: "radius", value: "max")
    }

    /// Adds the `radius` option.
    ///
    /// - Parameter value: The radius of the rounded corner effect on your image.
    /// Valid range: `1...10000`
    @discardableResult
    func radius(_ value: Int) -> Self {
        return appending(key: "radius", value: value)
    }

    /// Adds the `blur` option.
    ///
    /// - Parameter value: Specify the amount of blur to apply to the rounded edges of the image.
    /// Valid range: `0...20`
    @discardableResult
    func blur(_ value: Float = 0.3) -> Self {
        return appending(key: "blur", value: value)
    }

    /// Adds the `background` option.
    ///
    /// - Parameter value: Sets the background color to display where the rounded corners
    /// have removed part of the image.
    @discardableResult
    func background(_ value: UIColor) -> Self {
        return appending(key: "background", value: value.hexString)
    }
}

// MARK: - Deprecated

@available(*, deprecated, renamed: "RoundedCornersTransform")
typealias RoundCornersTransform = RoundedCornersTransform
