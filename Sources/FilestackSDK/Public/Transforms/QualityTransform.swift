//
//  QualityTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/// Sets the quality of your JPG or WEBP image without the danger of possibly generating a larger file.
public class QualityTransform: Transform {
    // MARK: - Lifecycle

    /// Initializes a `QualityTransform` object.
    ///
    /// - Parameter value: This task will take a JPG or WEBP file and reduce the file size of the image by reducing
    /// the quality. If the file is not a JPG, the original file will be returned. If after the conversion,
    /// the resulting file is not smaller than the original, the original file will be returned. Valid range: `1...100`
    public init(value: Int) {
        super.init(name: "quality")

        appending(key: "value", value: value)
    }
}
