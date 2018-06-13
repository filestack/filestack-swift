//
//  BlurFacesTransform.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 13/06/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

/**
 Blur selected faces contained inside an image.
 */
@objc(FSBlurFacesTransform) public class BlurFacesTransform: Transform {
  
  /**
   Initializes a `BlurFacesTransform` object.
   */
  public init() {
    super.init(name: "blur_faces")
  }
  
  /**
   Adds the `type` option.
   
   - Parameter value: An `TransformPixelateFacesType` value.
   */
  @discardableResult public func type(_ value: TransformPixelateFacesType) -> Self {
    return appending((key: "type", value: value))
  }
  
  /**
   Adds the `minSize` option.
   
   - Parameter value: This parameter is used to weed out objects that most likely
   are not faces. Valid range: `0.01...10000`
   */
  @discardableResult public func minSize(_ value: Float) -> Self {
    return appending((key: "minsize", value: value))
  }
  
  /**
   Adds the `maxSize` option.
   
   - Parameter value: This parameter is used to weed out objects that most likely
   are not faces. Valid range: `0.01...10000`
   */
  @discardableResult public func maxSize(_ value: Float) -> Self {
    return appending((key: "maxsize", value: value))
  }
  
  
  /**
   Adds the `buffer` option.
   
   - Parameter value: Adjusts the buffer around the face object as a percentage of
   the original object. Valid range: `0...1000`
   */
  @discardableResult public func buffer(_ value: Int) -> Self {
    return appending((key: "buffer", value: value))
  }
  
  /**
   Adds the `blur` option.
   
   - Parameter value: The amount to blur the pixelated faces. Valid range: `0...20`
   */
  @discardableResult public func blur(_ value: Float) -> Self {
    return appending((key: "blur", value: value))
  }
  
  /**
   Adds the `faces` option with value `all`.
   */
  @discardableResult public func allFaces() -> Self {
    return appending((key: "faces", value: "all"))
  }
  /**
   Adds the `faces` option.
   
   - Parameter value: The faces to be included in the crop.
   */
  @discardableResult public func faces(_ value: [Int]) -> Self {
    return appending((key: "faces", value: value))
  }
}
