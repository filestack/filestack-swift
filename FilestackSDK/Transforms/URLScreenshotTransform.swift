//
//  URLScreenshotTransform.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 15/06/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

/**
    Captures content of given URL.
    The URL screenshot task will not work for content that is located in areas that require you to login.
    If the content is not publicly visible, then it will not be captured.
 */
@objc(FSURLScreenshotTransform) public class URLScreenshotTransform: Transform {

    /**
        Initializes a `URLScreenshotTransform` object.
     */
    public init() {
        super.init(name: "urlscreenshot")
    }

    /**
        Changes the `agent` option from `desktop` to `mobile`.
     */
    @discardableResult public func mobileAgent() -> Self {
        return appending(key: "agent", value: "mobile")
    }

    /**
        Changes the `mode` option from `all` to `window`.
     */
    @discardableResult public func windowMode() -> Self {
        return appending(key: "mode", value: "window")
    }

    /**
        Adds the `width` option.

        - Parameter value: The new width in pixels. Valid range: `1...10000`
     */
    @discardableResult public func width(_ value: Int) -> Self {
        return appending(key: "width", value: value)
    }

    /**
        Adds the `height` option.

        - Parameter value: The new height in pixels. Valid range: `1...10000`
     */
    @discardableResult public func height(_ value: Int) -> Self {
        return appending(key: "height", value: value)
    }

    /**
        Adds the `delay` option.

        - Parameter value: Delay after which screenshot will be captured. Valid range: `1...20000`
     */
    @discardableResult public func delay(_ value: Int) -> Self {
        return appending(key: "delay", value: value)
    }

    /**
        Adds the `orientation` option.

        - Parameter value: Orientation for which screenshot will be captured.
     */
    @discardableResult public func orientation(_ value: TransformPageOrientation) -> Self {
        return appending(key: "orientation", value: value)
    }

    /**
        Adds the `device` option.

        - Parameter value: Device for which screenshot will be captured.
     */
    @discardableResult public func device(_ value: String) -> Self {
        return appending(key: "device", value: value)
    }
}

@available(*, deprecated, renamed: "URLScreenshotTransform") typealias UrlScreenshotTransform = URLScreenshotTransform
