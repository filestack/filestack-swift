//
//  NoMetadataTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/// Removes any metadata embedded in an image.
@objc(FSNoMetadataTransform)
public class NoMetadataTransform: Transform {
    // MARK: - Lifecycle

    /// Initializes a `NoMetadataTransform` object.
    @objc public init() {
        super.init(name: "no_metadata")
    }
}
