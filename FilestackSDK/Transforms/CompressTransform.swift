//
//  CompressTransform.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 15/06/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

/**
    Utilizes mozjpeg to offer improved compression for JPGS over the algorithm used for `output=compress:true`.
    It will not attempt to re-compress a previously compressed image.

    For the best results, compress should be the last task in your transformation chain.

    - Important: Works only with PNG and JPG files.
 */
@objc(FSCompressTransform) public class CompressTransform: Transform {

    /**
        Initializes a `CompressTransform` object.
     */
    public init() {
        super.init(name: "compress")
    }

    /**
        Adds the `metadata` option.

        - Parameter value: Sets if we want to keep metadata while compressing.
     */
    @discardableResult public func metadata(_ value: Bool) -> Self {
        return appending(key: "metadata", value: value)
    }
}
