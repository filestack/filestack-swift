//
//  AsciiTransform.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 14/06/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

/**
 Converts the image to black and white.
 */
@objc(FSAsciiTransform) public class AsciiTransform: Transform {
  
  /**
   Initializes a `AsciiTransform` object.
   */
  public init() {
    super.init(name: "ascii")
  }
  
  /**
   Adds the `background` option.
   
   - Parameter value: Sets the background color to display behind the image.
   */
  @discardableResult public func background(_ value: UIColor) -> Self {
    return appending(key: "background", value: value.hexString)
  }

  /**
   Adds the `foreground` option.
   
   - Parameter value: Sets the foreground color to display behind the image.
   */
  @discardableResult public func foreground(_ value: UIColor) -> Self {
    return appending(key: "foreground", value: value.hexString)
  }
  
  /**
   Adds the `colored` option.
   
   - Parameter value: Sets output as colored.
   */
  @discardableResult public func colored() -> Self {
    return appending(key: "colored", value: true)
  }
  
  /**
   Adds the `size` option.
   
   - Parameter value: The size of the overlayed image as a percentage of its original size.
   Valid range: `10...100`
   */
  @discardableResult public func size(_ value: Int) -> Self {
    return appending(key: "size", value: value)
  }

  /**
   Reverses the character set used to generate the ASCII output. Works well with dark backgrounds.
   */
  @discardableResult public func reverse() -> Self {
    return colored().appending(key: "reverse", value: true)
  }
}
