
//
//  TransformNoiseMode.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 15/06/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

/**
 Represents an image transform noise reduction type.
 */
@objc(FSTransformNoiseMode) public enum TransformNoiseMode: UInt, CustomStringConvertible {
  
  /// None
  case none
  
  /// Low
  case low
  
  /// Medium
  case medium
  
  /// High
  case high
  
  // MARK: - CustomStringConvertible
  
  /// Returns a `String` representation of self.
  public var description: String {
    switch self {
    case .none: return "none"
    case .low: return "low"
    case .medium: return "medium"
    case .high: return "high"
    }
  }
}
