//
//  PixelateFacesTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/// Pixelates selected faces contained inside an image.
public class PixelateFacesTransform: Transform {
    // MARK: - Lifecycle

    /// Initializes a `PixelateFacesTransform` object.
    public init() {
        super.init(name: "pixelate_faces")
    }
}

// MARK: - Public Functions

public extension PixelateFacesTransform {
    /// Adds `amount` option.
    ///
    /// - Parameter value: Valid range: `2...100`
    @discardableResult
    func amount(_ value: Int = 10) -> Self {
        return appending(key: "amount", value: value)
    }

    /// Adds the `type` option.
    ///
    /// - Parameter value: An `TransformShapeType` value.
    @discardableResult
    func type(_ value: TransformShapeType) -> Self {
        return appending(key: "type", value: value)
    }

    /// Adds the `minSize` option.
    ///
    /// - Parameter value: This parameter is used to weed out objects that most likely
    /// are not faces. Valid range: `0.01...10000`
    @discardableResult
    func minSize(_ value: Float) -> Self {
        return appending(key: "minsize", value: value)
    }

    /// Adds the `maxSize` option.
    ///
    /// - Parameter value: This parameter is used to weed out objects that most likely
    /// are not faces. Valid range: `0.01...10000`
    @discardableResult
    func maxSize(_ value: Float) -> Self {
        return appending(key: "maxsize", value: value)
    }

    /// Adds the `buffer` option.
    ///
    /// - Parameter value: Adjusts the buffer around the face object as a percentage of
    /// the original object. Valid range: `0...1000`
    @discardableResult
    func buffer(_ value: Int) -> Self {
        return appending(key: "buffer", value: value)
    }

    /// Adds the `blur` option.
    ///
    /// - Parameter value: The amount to blur the pixelated faces. Valid range: `0...20`
    @discardableResult
    func blur(_ value: Float) -> Self {
        return appending(key: "blur", value: value)
    }

    /// Adds the `faces` option with value `all`.
    @discardableResult
    func allFaces() -> Self {
        return appending(key: "faces", value: "all")
    }

    /// Adds the `faces` option.
    ///
    /// - Parameter value: The faces to be included in the crop.
    @discardableResult
    func faces(_ value: [Int]) -> Self {
        return appending(key: "faces", value: value)
    }
}
