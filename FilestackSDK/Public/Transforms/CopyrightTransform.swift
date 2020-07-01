//
//  CopyrightTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 13/08/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

/// Detects whether your image is copyright protected or not, and if it is protected, returns all types and related
/// details such as purchase link, etc.
@objc(FSCopyrightTransform)
public class CopyrightTransform: Transform {
    // MARK: - Lifecycle

    /// Initializes a `CopyrightTransform` object.
    @objc public init() {
        super.init(name: "copyright")
    }
}
