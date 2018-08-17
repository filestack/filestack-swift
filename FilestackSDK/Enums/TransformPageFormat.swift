//
//  TransformPageFormat.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/13/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/**
 Represents an image transform page format type.
 */
@objc(FSTransformPageFormat) public enum TransformPageFormat: UInt, CustomStringConvertible {
  
  /// A3
  case a3
  
  /// A4
  case a4
  
  /// A5
  case a5
  
  /// B4
  case b4
  
  /// B5
  case b5
  
  /// Letter
  case letter
  
  /// Legal
  case legal

  /// Tabloid
  case tabloid
  
  // MARK: - CustomStringConvertible
  
  /// Returns a `String` representation of self.
  public var description: String {
    switch self {
    case .a3: return "a3"
    case .a4: return "a4"
    case .a5: return "a5"
    case .b4: return "b4"
    case .b5: return "b5"
    case .letter: return "letter"
    case .legal: return "legal"
    case .tabloid: return "tabloid"
    }
  }
}
