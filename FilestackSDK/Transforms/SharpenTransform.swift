//
//  SharpenTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/**
 Applies a sharpening effect to the image.
 */
@objc(FSSharpenTransform) public class SharpenTransform: Transform {
  
  /**
   Initializes a `SharpenTransform` object.
   */
  public init() {
    super.init(name: "sharpen")
  }
  
  /**
   Adds the `amount` option.
   
   - Parameter value: The amount to sharpen the image. Valid range: `1...20`
   */
  @discardableResult public func amount(_ value: Int) -> Self {
    return appending((key: "amount", value: value))
  }
}
