//
//  SepiaTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/// Converts the image to sepia color.
@objc(FSSepiaTransform)
public class SepiaTransform: Transform {
    // MARK: - Lifecycle

    /// Initializes a `SepiaTransform` object.
    @objc public init() {
        super.init(name: "sepia")
    }
}

// MARK: - Public Functions

public extension SepiaTransform {
    /// Adds the `tone` option.
    ///
    /// - Parameter value: The value to set the sepia tone to. Valid range: `0...100`
    @discardableResult
    @objc func tone(_ value: Int) -> Self {
        return appending(key: "tone", value: value)
    }
}
