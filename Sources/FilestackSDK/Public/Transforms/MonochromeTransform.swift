//
//  MonochromeTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/// Converts the image to monochrome.
public class MonochromeTransform: Transform {
    // MARK: - Lifecycle

    /// Initializes a `MonochromeTransform` object.
    public init() {
        super.init(name: "monochrome")
    }
}
