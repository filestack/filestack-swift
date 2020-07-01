//
//  EnhanceTransform.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 15/06/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

/// Smartly analyzes a photo and performs color correction and other enhancements to improve the overall quality of the
/// image.
@objc(FSEnhanceTransform)
public class EnhanceTransform: Transform {
    // MARK: - Lifecycle

    /// Initializes a `EnhanceTransform` object.
    @objc public init() {
        super.init(name: "enhance")
    }
}

// MARK: - Public Functions

public extension EnhanceTransform {
    /// Adds the `preset` option.
    ///
    /// - Parameter value: The preset to use for enhancing the image. Only available on Pro plans or higher.
    @discardableResult
    @objc func preset(_ value: TransformEnhancePreset) -> Self {
        return appending(key: "preset", value: value)
    }
}
