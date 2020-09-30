//
//  DocumentDetectionTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 6/18/19.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

/// Detects your document in the image, transforms it to fully fit the image, and preprocesses it using de-noising
/// and distortion reduction in order to increase the accuracy of OCR engine in text extraction.
///
/// For more information, please check: https://www.filestack.com/docs/concepts/tasks/document-detection/
@objc(FSDocumentDetectionTransform)
public class DocumentDetectionTransform: Transform {
    // MARK: - Lifecycle

    /// Initializes a `DocumentDetectionTransform` object.
    @objc public init() {
        super.init(name: "doc_detection")
    }
}

// MARK: - Public Functions

public extension DocumentDetectionTransform {
    /// Adds the `coords` option.
    ///
    /// - Parameter value: If true, it returns the coordinates of the detected document in the image.
    @discardableResult
    @objc func coords(_ value: Bool) -> Self {
        return appending(key: "coords", value: value)
    }

    /// Adds the `preprocess` option.
    ///
    /// - Parameter value: If true, it returns the preprocessed image, otherwise the warped one will be returned instead.
    @discardableResult
    @objc func preprocess(_ value: Bool) -> Self {
        return appending(key: "preprocess", value: value)
    }
}
