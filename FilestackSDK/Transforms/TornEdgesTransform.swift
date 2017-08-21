//
//  TornEdgesTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/**
    Applies a torn edge border effect to the image.
 */
@objc(FSTornEdgesTransform) public class TornEdgesTransform: Transform {

    /**
        Initializes a `TornEdgesTransform` object.
     */
    public init() {

        super.init(name: "torn_edges")
    }

    /**
        Adds the `spread` option.

        - Parameter start: The spread's start value.
        - Parameter end: The spread's end value.
     */
    @discardableResult public func spread(start: Int, end: Int) -> Self {

        options.append((key: "spread", value: [start, end]))

        return self
    }

    /**
        Adds the `background` option.

        - Parameter value: Sets the background color to display behind the torn edge effect.
     */
    @discardableResult public func background(_ value: UIColor) -> Self {

        options.append((key: "background", value: value.hexString))
        
        return self
    }
}
