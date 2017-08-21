//
//  ConvertTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


/**
    Converts the image to a different format.
 */
@objc(FSConvertTransform) public class ConvertTransform: Transform {

    /**
        Initializes a `ConvertTransform` object.
     */
    public init() {

        super.init(name: "output")
    }

    /**
        Adds the `format` option.

        - Parameter value: The format to which you would like to convert the file.
            See [Filetype Conversions - Output](https://www.filestack.com/docs/image-transformations/conversion)
            for more information on supported formats.
     */
    @discardableResult public func format(_ value: String) -> Self {

        options.append((key: "format", value: value))

        return self
    }

    /**
        Adds the `background` option.

        - Parameter value: Set a background color when converting transparent .png files
            into other file types.
     */
    @discardableResult public func background(_ value: UIColor) -> Self {

        options.append((key: "background", value: value.hexString))

        return self
    }

    /**
        Adds the `page` option.

        - Parameter value: If you are converting a file that contains multiple pages such as a PDF
           or PowerPoint file, you can extract a specific page using the page parameter.
           Valid range: `1...10000`
     */
    @discardableResult public func page(_ value: Int) -> Self {

        options.append((key: "page", value: value))

        return self
    }

    /**
        Adds the `density` option.

        - Parameter value: You can adjust the density when converting documents like PowerPoint,
            PDF, AI and EPS files to image formats like JPG or PNG. Valid range: `1...500`
     */
    @discardableResult public func density(_ value: Int) -> Self {

        options.append((key: "density", value: value))

        return self
    }

    /**
        Adds the `compress` option.

        - Parameter value: If true, takes advantage of Filestack's image compression which utilizes
            JPEGtran and OptiPNG.
     */
    @discardableResult public func compress(_ value: Bool) -> Self {

        options.append((key: "compress", value: value))

        return self
    }

    /**
        Adds the `quality` option.

        - Parameter value: You can change the quality (and reduce the file size) of JPEG images
        by using the quality parameter. Valid range: `1...100`
     */
    @discardableResult public func quality(_ value: Int) -> Self {

        options.append((key: "quality", value: value))

        return self
    }

    /**
        Adds the `quality` option with value set to "input".
     */
    @discardableResult public func preserveInputQuality() -> Self {

        options.append((key: "quality", value: "input"))

        return self
    }


    /**
        Adds the `strip` option.

        - Parameter value: If true, it will remove any metadata embedded in an image.
     */
    @discardableResult public func strip(_ value: Bool) -> Self {

        options.append((key: "strip", value: value))

        return self
    }

    /**
        Adds the `colorSpace` option.

        - Parameter value: An `TransformColorSpace` value.
     */
    @discardableResult public func colorSpace(_ value: TransformColorSpace) -> Self {

        options.append((key: "colorspace", value: value))

        return self
    }

    /**
        Adds the `secure` option.

        - Parameter value: This parameter applies to conversions of HTML and SVG sources.
            If true, the HTML or SVG file will be stripped of any insecure tags (HTML sanitization).
     */
    @discardableResult public func secure(_ value: Bool) -> Self {

        options.append((key: "secure", value: value))

        return self
    }

    /**
        Adds the `docInfo` option.

        - Parameter value: The docinfo parameter can be used to get information about a document,
            such as the number of pages and the dimensions of the file. This information is
            delivered as a JSON object that will look like this:
            ```
            {
                "numpages":41,
                "dimensions":
                {
                    "width":538,
                    "height":718
                }
            }
            ```
     */
    @discardableResult public func docInfo(_ value: Bool) -> Self {

        options.append((key: "docinfo", value: value))

        return self
    }

    /**
        Adds the `pageFormat` option.

        - Parameter value: An `TransformPageFormat` value.
     */
    @discardableResult public func pageFormat(_ value: TransformPageFormat) -> Self {

        options.append((key: "pageformat", value: value))

        return self
    }

    /**
        Adds the `pageOrientation` option.

        - Parameter value: An `TransformPageOrientation` value.
     */
    @discardableResult public func pageOrientation(_ value: TransformPageOrientation) -> Self {

        options.append((key: "pageorientation", value: value))

        return self
    }
}
