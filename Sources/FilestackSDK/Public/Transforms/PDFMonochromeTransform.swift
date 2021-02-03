//
//  PDFMonochromeTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 6/18/19.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

/// Converts a PDF to black and white version.
public class PDFMonochromeTransform: Transform {
    // MARK: - Lifecycle

    /// Initializes a `PDFMonochromeTransform` object.
    public init() {
        super.init(name: "monochrome")
    }
}
