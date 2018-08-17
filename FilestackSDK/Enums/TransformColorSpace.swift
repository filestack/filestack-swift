//
//  TransformColorSpace.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/13/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/**
 Represents an image transform color space type.
 */
@objc(FSTransformColorSpace) public enum TransformColorSpace: UInt, CustomStringConvertible {
  
  /// RGB
  case rgb
  
  /// CMYK
  case cmyk
  
  /// Input
  case input
  
  // MARK: - CustomStringConvertible
  
  /// Returns a `String` representation of self.
  public var description: String {
    switch self {
    case .rgb: return "rgb"
    case .cmyk: return "cmyk"
    case .input: return "input"
    }
  }
}
