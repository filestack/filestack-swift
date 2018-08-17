//
//  ResizeTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/**
 Resizes the image to a given width and height using a particular fit and alignment mode.
 */
@objc(FSResizeTransform) public class ResizeTransform: Transform {
  
  /**
   Initializes a `ResizeTransform` object.
   */
  public init() {
    super.init(name: "resize")
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
   Adds the `fit` option.
   
   - Parameter value: An `TransformFit` value.
   */
  @discardableResult public func fit(_ value: TransformFit) -> Self {
    return appending(key: "fit", value: value)
  }
  
  /**
   Adds the `align` option.
   
   - Parameter value: An `TransformAlign` value.
   */
  @discardableResult public func align(_ value: TransformAlign) -> Self {
    return appending(key: "align", value: value)
  }
}
