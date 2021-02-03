//
//  OCRTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 13/08/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

/// Detects both printed and handwritten texts in images. The result follows the standard JSON format containing all of
/// the details regarding detected text areas, lines, and words.
public class OCRTransform: Transform {
    // MARK: - Lifecycle

    /// Initializes an `OCRTransform` object.
    public init() {
        super.init(name: "ocr")
    }
}
