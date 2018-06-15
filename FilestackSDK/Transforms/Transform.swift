//
//  Transform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

typealias TaskOption = (key: String, value: Any?)
typealias Task = (name: String, options: [TaskOption]?)

/// :nodoc:
@objc(FSTransform) public class Transform: NSObject {
  
  var options = [TaskOption]()
  var name: String
  
  var task: Task {
    return Task(name: name, options: options)
  }
  
  init(name: String) {
    self.name = name
  }
}

extension Transform {
  typealias AV = AVTransform
  typealias BlackAndWhite = BlackAndWhiteTransform
  typealias BlurFaces = BlurFacesTransform
  typealias Border = BorderTransform
  typealias Circle = CircleTransform
  typealias Convert = ConvertTransform
  typealias CropFaces = CropFacesTransform
  typealias Crop = CropTransform
  typealias DetectFaces = DetectFacesTransform
  typealias Flip = FlipTransform
  typealias Flop = FlopTransform
  typealias Modulate = ModulateTransform
  typealias Monochrome = MonochromeTransform
  typealias NoMetadata = NoMetadataTransform
  typealias PixelateFaces = PixelateFacesTransform
  typealias Polaroid = PolaroidTransform
  typealias Quality = QualityTransform
  typealias Resize = ResizeTransform
  typealias Rotate = RotateTransform
  typealias RoundCorners = RoundCornersTransform
  typealias Sepia = SepiaTransform
  typealias Shadow = ShadowTransform
  typealias Sharpen = SharpenTransform
  typealias TornEdges = TornEdgesTransform
  typealias Vignette = VignetteTransform
  typealias Watermark = WatermarkTransform
  typealias Zip = ZipTransform
}

extension Transform {
  @discardableResult func appending(key: String, value: Any?) -> Self {
    options.append((key: key, value: value))
    return self
  }
}

