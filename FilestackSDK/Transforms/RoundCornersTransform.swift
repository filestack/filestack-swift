//
//  RoundCornersTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/**
 Rounds the image's corners.
 */
@objc(FSRoundCornersTransform) public class RoundCornersTransform: Transform {
  
  /**
   Initializes a `RoundCornersTransform` object.
   */
  public init() {
    super.init(name: "round_corners")
  }
  
  /**
   Adds the `radius` option with value set to "max".
   */
  @discardableResult public func maxRadius() -> Self {
    return appending((key: "radius", value: "max"))
  }
  
  /**
   Adds the `radius` option.
   
   - Parameter value: The radius of the rounded corner effect on your image.
   Valid range: `1...10000`
   */
  @discardableResult public func radius(_ value: Int) -> Self {
    return appending((key: "radius", value: value))
  }
  
  /**
   Adds the `blur` option.
   
   - Parameter value: Specify the amount of blur to apply to the rounded edges of the image.
   Valid range: `0...20`
   */
  @discardableResult public func blur(_ value: Float = 0.3) -> Self {
    return appending((key: "blur", value: value))
  }
  
  /**
   Adds the `background` option.
   
   - Parameter value: Sets the background color to display where the rounded corners
   have removed part of the image.
   */
  @discardableResult public func background(_ value: UIColor) -> Self {
    return appending((key: "background", value: value.hexString))
  }
}
