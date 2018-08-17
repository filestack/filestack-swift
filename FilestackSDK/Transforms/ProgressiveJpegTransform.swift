//
//  ProgressiveJpegTransform.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 15/06/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

/**
 Convert an image to progressive JPEG. This is ideal for large images that will be displayed while downloading over a slow connection, allowing a reasonable preview after receiving only a portion of the data. However, support for progressive JPEGs is not universal. When progressive JPEGs are received by programs that do not support them (such as versions of Internet Explorer before Windows 7) the software displays the image only after it has been completely downloaded.
 */
@objc(FSProgressiveJpegTransform) public class ProgressiveJpegTransform: Transform {
  
  /**
   Initializes a `PolaroidTransform` object.
   */
  public init() {
    super.init(name: "pjpg")
  }
  
  /**
   Adds the `quality` option.
   
   - Parameter value: You can set the quality of output file. Valid range: `1...100`
   */
  @discardableResult public func quality(_ value: Int) -> Self {
    return appending(key: "quality", value: value)
  }

  /**
   Adds the `metadata` option.
   
   - Parameter value: Sets if we want to keep metadata while cnverting.
   */
  @discardableResult public func metadata(_ value: Bool) -> Self {
    return appending(key: "metadata", value: value)
  }
}
