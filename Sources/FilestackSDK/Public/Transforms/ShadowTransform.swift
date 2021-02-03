//
//  ShadowTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import UIKit

/// Applies a shadow border effect to the image.
public class ShadowTransform: Transform {
    // MARK: - Lifecycle

    /// Initializes a `ShadowTransform` object.
    public init() {
        super.init(name: "shadow")
    }
}

// MARK: - Public Functions

public extension ShadowTransform {
    /// Adds the `blur` option.
    ///
    /// - Parameter value: Sets the level of blur for the shadow effect. Valid range: `0...20`
    @discardableResult
    func blur(_ value: Int) -> Self {
        return appending(key: "blur", value: value)
    }

    /// Adds the `opacity` option.
    ///
    /// - Parameter value: Sets the opacity level of the shadow effect. Vaid range: `0 to 100`
    @discardableResult
    func opacity(_ value: Int) -> Self {
        return appending(key: "opacity", value: value)
    }

    /// Adds the `vector` option.
    ///
    /// - Parameter x: Sets the shadow's X offset. Valid range: `-1000 to 1000`
    /// - Parameter y: Sets the shadow's Y offset. Valid range: `-1000 to 1000`
    @discardableResult
    func vector(x: Int, y: Int) -> Self {
        return appending(key: "vector", value: [x, y])
    }

    /// Adds the `color` option.
    ///
    /// - Parameter value: Sets the shadow color.
    @discardableResult
    func color(_ value: UIColor) -> Self {
        return appending(key: "color", value: value.hexString)
    }

    /// Adds the `background` option.
    ///
    /// - Parameter value: Sets the background color to display behind the image,
    /// like a matte the shadow is cast on.
    @discardableResult
    func background(_ value: UIColor) -> Self {
        return appending(key: "background", value: value.hexString)
    }
}
