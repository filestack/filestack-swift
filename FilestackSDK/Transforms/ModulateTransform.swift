//
//  ModulateTransform.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 14/06/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

/**
 Changes the image brightness, saturation and hue.
 */
@objc(FSModulateTransform) public class ModulateTransform: Transform {
    /**
     Initializes a `ModulateTransform` object.
     */
    @objc public init() {
        super.init(name: "modulate")
    }

    /**
     Adds `brightness` option.

     - Parameter value: Valid range: `0...10000`
     */
    @objc @discardableResult public func brightness(_ value: Int) -> Self {
        return appending(key: "brightness", value: value)
    }

    /**
     Adds `saturation` option.

     - Parameter value: Valid range: `0...10000`
     */
    @objc @discardableResult public func saturation(_ value: Int) -> Self {
        return appending(key: "saturation", value: value)
    }

    /**
     Adds `hue` option.

     - Parameter value: Valid range: `0...359`
     */
    @objc @discardableResult public func hue(_ value: Int) -> Self {
        return appending(key: "hue", value: value)
    }
}
