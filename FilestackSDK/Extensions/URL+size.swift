//
//  URL+size.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/18/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

extension URL {
  
  func size() -> UInt64? {
    let manager = FileManager.default
    guard let attributtes = try? manager.attributesOfItem(atPath: relativePath) else { return nil }
    return attributtes[.size] as? UInt64
  }
}
