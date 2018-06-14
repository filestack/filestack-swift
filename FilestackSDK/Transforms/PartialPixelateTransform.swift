//
//  PartialPixelateTransform.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 14/06/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

/**
 Change image brightness, saturation and hue.
 */
@objc(FSPartialPixelateTransform) public class PartialPixelateTransform: Transform, PartialCoverTransformExtension {
  
  /**
   Initializes a `PartialPixelateTransform` object.
   */
  public init() {
    super.init(name: "partial_pixelate")
    let values = objects
      .map { "[\($0.origin.x),\($0.origin.y),\($0.size.width),\($0.size.height)]" }
      .joined(separator: ",")
    options.append((key: "objects", value: "[\(values)]"))
  }
}
