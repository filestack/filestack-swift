//
//  SecureForWorkTransform.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 20/06/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

/// Returns whether the image if safe to display.
@objc(FSSecureForWorkTransform)
public class SecureForWorkTransform: Transform {
    // MARK: - Lifecycle

    /// Initializes a `SecureForWorkTransform` object.
    @objc public init() {
        super.init(name: "sfw")
    }
}
