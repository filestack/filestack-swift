//
//  TornEdgesTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/// Applies a torn edge border effect to the image.
@objc(FSTornEdgesTransform)
public class TornEdgesTransform: Transform {
    // MARK: - Lifecycle

    /// Initializes a `TornEdgesTransform` object.
    @objc public init() {
        super.init(name: "torn_edges")
    }
}

// MARK: - Public Functions

public extension TornEdgesTransform {
    /// Adds the `spread` option.
    ///
    /// - Parameter start: The spread's start value.
    /// - Parameter end: The spread's end value.
    @discardableResult
    @objc func spread(start: Int, end: Int) -> Self {
        return appending(key: "spread", value: [start, end])
    }

    /// Adds the `background` option.
    ///
    /// - Parameter value: Sets the background color to display behind the torn edge effect.
    @discardableResult
    @objc func background(_ value: UIColor) -> Self {
        return appending(key: "background", value: value.hexString)
    }
}
