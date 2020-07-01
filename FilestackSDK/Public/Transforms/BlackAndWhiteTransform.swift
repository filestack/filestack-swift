//
//  BlackAndWhiteTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/// Converts the image to black and white.
@objc(FSBlackAndWhiteTransform)
public class BlackAndWhiteTransform: Transform {
    // MARK: - Lifecycle

    /// Initializes a `BlackAndWhiteTransform` object.
    @objc public init() {
        super.init(name: "blackwhite")
    }
}

// MARK: - Public Functions

public extension BlackAndWhiteTransform {
    /// Adds the `threshold` option.
    ///
    /// - Parameter value: Controls the balance between black and white (contrast) in
    /// the returned image. Valid range: `1...100`
    @discardableResult
    @objc func threshold(_ value: Int) -> Self {
        return appending(key: "threshold", value: value)
    }
}
