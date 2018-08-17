//
//  BorderTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/**
 Applies a border effect to the image.
 */
@objc(FSBorderTransform) public class BorderTransform: Transform {
  
  /**
   Initializes a `BorderTransform` object.
   */
  public init() {
    super.init(name: "border")
  }
  
  /**
   Adds the `width` option.
   
   - Parameter value: Sets the width in pixels of the border to render around the image.
   Valid range: `1...1000`
   */
  @discardableResult public func width(_ value: Int) -> Self {
    return appending(key: "width", value: value)
  }
  
  /**
   Adds the `color` option.
   
   - Parameter value: Sets the color of the border to render around the image.
   */
  @discardableResult public func color(_ value: UIColor) -> Self {
    return appending(key: "color", value: value.hexString)
  }
  
  /**
   Adds the `background` option.
   
   - Parameter value: Sets the background color to display behind the image.
   */
  @discardableResult public func background(_ value: UIColor) -> Self {
    return appending(key: "background", value: value.hexString)
  }
}
