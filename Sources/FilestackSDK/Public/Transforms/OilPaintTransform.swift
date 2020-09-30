//
//  OilPaintTransform.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 14/06/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

/// Change the image to look like it was oil painted.
@objc(FSOilPaintTransform)
public class OilPaintTransform: Transform {
    // MARK: - Lifecycle

    /// Initializes an `OilPaintTransform` object.
    @objc public init() {
        super.init(name: "oil_paint")
    }
}

// MARK: - Public Functions

public extension OilPaintTransform {
    /// Adds `amount` option.
    ///
    /// - Parameter value: Valid range: `2...100`
    @discardableResult
    @objc func amount(_ value: Int) -> Self {
        return appending(key: "amount", value: value)
    }
}
