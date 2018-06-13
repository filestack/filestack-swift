//
//  PixelateFacesTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


/**
 Pixelates selected faces contained inside an image.
 */
@objc(FSPixelateFacesTransform) public class PixelateFacesTransform: Transform {
  
  /**
   Initializes a `PixelateFacesTransform` object.
   */
  public init() {
    
    super.init(name: "pixelate_faces")
  }
  
  /**
   Adds the `type` option.
   
   - Parameter value: An `TransformPixelateFacesType` value.
   */
  @discardableResult public func type(_ value: TransformPixelateFacesType) -> Self {
    
    options.append((key: "type", value: value))
    
    return self
  }
  
  /**
   Adds the `minSize` option.
   
   - Parameter value: This parameter is used to weed out objects that most likely
   are not faces. Valid range: `0.01...10000`
   */
  @discardableResult public func minSize(_ value: Float) -> Self {
    
    options.append((key: "minsize", value: value))
    
    return self
  }
  
  /**
   Adds the `maxSize` option.
   
   - Parameter value: This parameter is used to weed out objects that most likely
   are not faces. Valid range: `0.01...10000`
   */
  @discardableResult public func maxSize(_ value: Float) -> Self {
    
    options.append((key: "maxsize", value: value))
    
    return self
  }
  
  
  /**
   Adds the `buffer` option.
   
   - Parameter value: Adjusts the buffer around the face object as a percentage of
   the original object. Valid range: `0...1000`
   */
  @discardableResult public func buffer(_ value: Int) -> Self {
    
    options.append((key: "buffer", value: value))
    
    return self
  }
  
  /**
   Adds the `blur` option.
   
   - Parameter value: The amount to blur the pixelated faces. Valid range: `0...20`
   */
  @discardableResult public func blur(_ value: Float) -> Self {
    
    options.append((key: "blur", value: value))
    
    return self
  }
  
  /**
   Adds the `faces` option with value `all`.
   */
  @discardableResult public func allFaces() -> Self {
    
    options.append((key: "faces", value: "all"))
    
    return self
  }
  /**
   Adds the `faces` option.
   
   - Parameter value: The faces to be included in the crop.
   */
  @discardableResult public func faces(_ value: [Int]) -> Self {
    
    options.append((key: "faces", value: value))
    
    return self
  }
}


///**
// Pixelates selected faces contained inside an image.
//
// - Parameter faces: The faces to be pixelated.
// - Parameter minSize: This parameter is used to weed out objects that most likely
// are not faces. Valid range: `0.01...10000`
// - Parameter maxSize: This parameter is used to weed out objects that most likely
// are not faces. Valid range: `0.01...10000`
// - Parameter buffer: Adjusts the buffer around the face object as a percentage of
// the original object. Valid range: `0...1000`
// - Parameter blur: The amount to blur the pixelated faces. Valid range: `0...20`
// - Parameter type: An `TransformPixelateFacesType` value.
// */
//@discardableResult public func pixelateFaces(faces: [Int],
//                                             minSize: Float? = nil,
//                                             maxSize: Float? = nil,
//                                             buffer: Int,
//                                             blur: Float? = nil,
//                                             type: TransformPixelateFacesType? = nil) -> Self {
//
//    return pPixelateFaces(faces: faces,
//                          minSize: minSize,
//                          maxSize: maxSize,
//                          buffer: buffer,
//                          blur: blur,
//                          type: type)
//}
//
///**
// Pixelates all the faces contained inside an image.
//
// - Parameter minSize: This parameter is used to weed out objects that most likely
// are not faces. Valid range: `0.01...10000`
// - Parameter maxSize: This parameter is used to weed out objects that most likely
// are not faces. Valid range: `0.01...10000`
// - Parameter buffer: Adjusts the buffer around the face object as a percentage of
// the original object. Valid range: `0...1000`
// - Parameter blur: The amount to blur the pixelated faces. Valid range: `0...20`
// - Parameter type: An `TransformPixelateFacesType` value.
// */
//@discardableResult public func pixelateFacesAll(minSize: Float? = nil,
//                                                maxSize: Float? = nil,
//                                                buffer: Int,
//                                                blur: Float? = nil,
//                                                type: TransformPixelateFacesType? = nil) -> Self {
//
//    return pPixelateFaces(faces: "all",
//                          minSize: minSize,
//                          maxSize: maxSize,
//                          buffer: buffer,
//                          blur: blur,
//                          type: type)
//}
