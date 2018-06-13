//
//  FlopTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


/**
 Flips/mirrors the image horizontally.
 */
@objc(FSFlopTransform) public class FlopTransform: Transform {
  
  /**
   Initializes a `FlopTransform` object.
   */
  public init() {
    
    super.init(name: "flop")
  }
}
