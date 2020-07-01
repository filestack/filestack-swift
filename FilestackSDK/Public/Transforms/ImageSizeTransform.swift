//
//  ImageSizeTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 6/19/19.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

/// Returns the width and height of a given image.
@objc(FSImageSizeTransform)
public class ImageSizeTransform: Transform {
    // MARK: - Lifecycle

    /// Initializes an `ImageSizeTransform` object.
    @objc public init() {
        super.init(name: "imagesize")
    }
}
