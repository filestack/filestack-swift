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
@objc(FSBlurFacesTransform) public class BlurFacesTransform: Transform, CoverFacesTransformExtension {
  
  /**
   Initializes a `BlurFacesTransform` object.
   */
  public init() {
    super.init(name: "blur_faces")
  }
  
  /**
   Adds `amount` option.
   
   - Parameter value: Valid range: `0...20`
   */
  @discardableResult func amount(_ value: Float = 10) -> Self {
    return appending(key: "amount", value: value)
  }
}
