//
//  PDFConvertTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 6/18/19.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

/**
 Converts a PDF to a specific orientation, page format, and, optionally, extracts specific pages.
 */
@objc(FSPDFConvertTransform) public class PDFConvertTransform: Transform {
    /**
     Initializes a `PDFConvertTransform` object.
     */
    @objc public init() {
        super.init(name: "pdfconvert")
    }

    /**
     Adds the `pageOrientation` option.

     - Parameter value: A `TransformPageOrientation` value.
     */
    @objc @discardableResult public func pageOrientation(_ value: TransformPageOrientation) -> Self {
        return appending(key: "pageorientation", value: value)
    }

    /**
     Adds the `pageFormat` option.

     - Parameter value: A `TransformPageFormat` value.
     */
    @objc @discardableResult public func pageFormat(_ value: TransformPageFormat) -> Self {
        return appending(key: "pageformat", value: value)
    }

    /**
     Adds the `pages` option.

     - Parameter value: An array of page numbers.
     */
    @objc @discardableResult func pages(_ value: [Int]) -> Self {
        return appending(key: "pages", value: value)
    }
}
