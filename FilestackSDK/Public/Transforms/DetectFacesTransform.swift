//
//  DetectFacesTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/// Detects the faces contained inside an image.
@objc(FSDetectFacesTransform)
public class DetectFacesTransform: Transform {
    // MARK: - Lifecycle

    /// Initializes a `DetectFacesTransform` object.
    @objc public init() {
        super.init(name: "detect_faces")
    }
}

// MARK: - Public Functions

public extension DetectFacesTransform {
    /// Adds the `minSize` option.
    ///
    /// - Parameter value: This parameter is used to weed out objects that most likely
    /// are not faces. Valid range: `0.01...10000`
    @discardableResult
    @objc func minSize(_ value: Float) -> Self {
        return appending(key: "minsize", value: value)
    }

    /// Adds the `maxSize` option.
    ///
    /// - Parameter value: This parameter is used to weed out objects that most likely
    /// are not faces. Valid range: `0.01...10000`
    @discardableResult
    @objc func maxSize(_ value: Float) -> Self {
        return appending(key: "maxsize", value: value)
    }

    /// Adds the `color` option.
    ///
    /// - Parameter value: Will change the color of the "face object" boxes and text.
    @discardableResult
    @objc func color(_ value: UIColor) -> Self {
        return appending(key: "color", value: value.hexString)
    }

    /// Adds the `export` option.
    ///
    /// - Parameter value: If true, it will export all face objects to a JSON object.
    @discardableResult
    @objc func export(_ value: Bool) -> Self {
        return appending(key: "export", value: value)
    }
}
