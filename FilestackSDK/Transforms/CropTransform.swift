//
//  CropTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/**
 Crops the image to a specified rectangle.
 */
@objc(FSCropTransform) public class CropTransform: Transform {
  
  /**
   Initializes a `CropTransform` object.
   
   - Parameter x: The starting point X coordinate.
   - Parameter y: The starting point Y coordinate.
   - Parameter width: The output image's width.
   - Parameter height: The output image's height.
   */
  public init(x: Int, y: Int, width: Int, height: Int) {
    super.init(name: "crop")
    options.append((key: "dim", value: [x, y, width, height]))
  }
}
