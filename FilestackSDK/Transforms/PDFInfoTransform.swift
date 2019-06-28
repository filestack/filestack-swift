//
//  PDFInfoTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 6/18/19.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

/**
 Gets information about a PDF document.

 For more information see https://www.filestack.com/docs/api/processing/#pdf-info
 */
@objc(FSPDFInfoTransform) public class PDFInfoTransform: Transform {
    /**
     Initializes a `PDFInfoTransform` object.
     */
    public init() {
        super.init(name: "pdfinfo")
    }

    /**
     Adds the `colorinfo` option.
     */
    @discardableResult public func colorInfo() -> Self {
        return appending(key: "colorinfo", value: true)
    }
}
