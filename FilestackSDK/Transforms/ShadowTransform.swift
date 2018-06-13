//
//  ShadowTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


/**
 Applies a shadow border effect to the image.
 */
@objc(FSShadowTransform) public class ShadowTransform: Transform {
  
  /**
   Initializes a `ShadowTransform` object.
   */
  public init() {
    
    super.init(name: "shadow")
  }
  
  /**
   Adds the `blur` option.
   
   - Parameter value: Sets the level of blur for the shadow effect. Valid range: `0...20`
   */
  @discardableResult public func blur(_ value: Int) -> Self {
    
    options.append((key: "blur", value: value))
    
    return self
  }
  
  /**
   Adds the `opacity` option.
   
   - Parameter value: Sets the opacity level of the shadow effect. Vaid range: `0 to 100`
   */
  @discardableResult public func opacity(_ value: Int) -> Self {
    
    options.append((key: "opacity", value: value))
    
    return self
  }
  
  /**
   Adds the `vector` option.
   
   - Parameter x: Sets the shadow's X offset. Valid range: `-1000 to 1000`
   - Parameter y: Sets the shadow's Y offset. Valid range: `-1000 to 1000`
   */
  @discardableResult public func vector(x: Int, y: Int) -> Self {
    
    options.append((key: "vector", value: [x, y]))
    
    return self
  }
  
  /**
   Adds the `color` option.
   
   - Parameter value: Sets the shadow color.
   */
  @discardableResult public func color(_ value: UIColor) -> Self {
    
    options.append((key: "color", value: value.hexString))
    
    return self
  }
  
  /**
   Adds the `background` option.
   
   - Parameter value: Sets the background color to display behind the image,
   like a matte the shadow is cast on.
   */
  @discardableResult public func background(_ value: UIColor) -> Self {
    
    options.append((key: "background", value: value.hexString))
    
    return self
  }
}
