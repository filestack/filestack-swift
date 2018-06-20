//
//  SecureForWorkTransform.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 20/06/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

/**
 Returns JSON with flag saying if image if safe to display.
 Possible values: { "sfw": true } or { "sfw": false } depending on detected content.
 */
@objc(FSSecureForWorkTransform) public class SecureForWorkTransform: Transform {
  
  /**
   Initializes a `SecureForWorkTransform` object.
   */
  public init() {
    super.init(name: "sfw")
  }
}
