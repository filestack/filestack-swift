//
//  FacesTransform.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 13/06/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

/**
  Shared interface for BlurFacesTransform and PixelateFacesTransform
 */
protocol CoverFacesTransformExtension {
  
  /**
   Adds the `type` option.
   
   - Parameter value: An `TransformShapeType` value.
   */
  @discardableResult func type(_ value: TransformShapeType) -> Self

  /**
   Adds the `minSize` option.
   
   - Parameter value: This parameter is used to weed out objects that most likely
   are not faces. Valid range: `0.01...10000`
   */
  @discardableResult func minSize(_ value: Float) -> Self
  
  /**
   Adds the `maxSize` option.
   
   - Parameter value: This parameter is used to weed out objects that most likely
   are not faces. Valid range: `0.01...10000`
   */
  @discardableResult func maxSize(_ value: Float) -> Self
  
  /**
   Adds the `buffer` option.
   
   - Parameter value: Adjusts the buffer around the face object as a percentage of
   the original object. Valid range: `0...1000`
   */
  @discardableResult func buffer(_ value: Int) -> Self
  
  /**
   Adds the `blur` option.
   
   - Parameter value: The amount to blur the pixelated faces. Valid range: `0...20`
   */
  @discardableResult func blur(_ value: Float) -> Self
  
  /**
   Adds the `faces` option with value `all`.
   */
  @discardableResult func allFaces() -> Self
  
  /**
   Adds the `faces` option.
   
   - Parameter value: The faces to be included in the crop.
   */
  @discardableResult func faces(_ value: [Int]) -> Self
}

extension CoverFacesTransformExtension where Self: Transform {

  @discardableResult func type(_ value: TransformShapeType) -> Self {
    return appending((key: "type", value: value))
  }
  
  @discardableResult func minSize(_ value: Float) -> Self {
    return appending((key: "minsize", value: value))
  }
  
  @discardableResult func maxSize(_ value: Float) -> Self {
    return appending((key: "maxsize", value: value))
  }
  
  @discardableResult func buffer(_ value: Int) -> Self {
    return appending((key: "buffer", value: value))
  }
  
  @discardableResult func blur(_ value: Float) -> Self {
    return appending((key: "blur", value: value))
  }
  
  @discardableResult func allFaces() -> Self {
    return appending((key: "faces", value: "all"))
  }

  @discardableResult func faces(_ value: [Int]) -> Self {
    return appending((key: "faces", value: value))
  }
}
