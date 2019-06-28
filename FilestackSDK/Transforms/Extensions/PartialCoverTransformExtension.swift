//
//  PartialCoverTransformExtension.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 14/06/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

/**
 Shared interface for PartialBlurTransform and PartialPixelateTransform
 */
protocol PartialCoverTransformExtension {
    /**
     Adds `amount` option.

     - Parameter value: Valid range: `2...100`
     */
    @discardableResult func amount(_ value: Int) -> Self

    /**
     Adds the `blur` option.

     - Parameter value: The amount to blur the pixelated faces. Valid range: `0...20`
     */
    @discardableResult func blur(_ value: Float) -> Self

    /**
     Adds the `type` option.

     - Parameter value: An `TransformShapeType` value.
     */
    @discardableResult func type(_ value: TransformShapeType) -> Self
}

extension PartialCoverTransformExtension where Self: Transform {
    @discardableResult func amount(_ value: Int) -> Self {
        return appending(key: "amount", value: value)
    }

    @discardableResult func blur(_ value: Float) -> Self {
        return appending(key: "blur", value: value)
    }

    @discardableResult func type(_ value: TransformShapeType) -> Self {
        return appending(key: "type", value: value)
    }
}
