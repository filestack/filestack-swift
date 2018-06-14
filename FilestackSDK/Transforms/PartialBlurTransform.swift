//
//  PartialBlurTransform.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 14/06/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

/**
 Change image brightness, saturation and hue.
 */
@objc(FSPartialBlurTransform) public class PartialBlurTransform: Transform, PartialCoverTransformExtension {
  
  /**
   Initializes a `PartialBlurTransform` object.
   */
  public init(objects: [CGRect]) {
    super.init(name: "partial_blur")
    let values = objects
      .map { "[\($0.origin.x),\($0.origin.y),\($0.size.width),\($0.size.height)]" }
      .joined(separator: ",")
    options.append((key: "objects", value: "[\(values)]"))
  }
}
