//
//  PDFConvertTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 6/18/19.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

/// Converts a PDF to a specific orientation, page format, and, optionally, extracts specific pages.
public class PDFConvertTransform: Transform {
    // MARK: - Lifecycle

    /// Initializes a `PDFConvertTransform` object.
    public init() {
        super.init(name: "pdfconvert")
    }
}

// MARK: - Public Functions

public extension PDFConvertTransform {
    /// Adds the `pageOrientation` option.
    ///
    /// - Parameter value: A `TransformPageOrientation` value.
    @discardableResult
    func pageOrientation(_ value: TransformPageOrientation) -> Self {
        return appending(key: "pageorientation", value: value)
    }

    /// Adds the `pageFormat` option.
    ///
    /// - Parameter value: A `TransformPageFormat` value.
    @discardableResult
    func pageFormat(_ value: TransformPageFormat) -> Self {
        return appending(key: "pageformat", value: value)
    }

    /// Adds the `pages` option.
    ///
    /// - Parameter value: An array of page numbers.
    @discardableResult
    func pages(_ value: [Int]) -> Self {
        return appending(key: "pages", value: value)
    }
}
