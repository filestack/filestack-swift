//
//  CacheTransform.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 15/06/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

/**
 Takes the file or files that are passed into it and compresses them into a zip file.
 */
@objc(FSCacheTransform) public class CacheTransform: Transform {
  
  /**
   Initializes a `CacheTransform` object.
   */
  public init(_ value: Bool) {
    super.init(name: "cache")
  }
  
  /**
   Adds the `false` option.
   
   - Parameter value: Set cache to false to ensure that you always receive a newly converted file.
   This setting is only recommended for testing purposes because every time a URL using cache=false loads,
   it will count against your conversion quota.
   */
  @discardableResult public func turnOff() -> Self {
    return appending(key: "false", value: nil)
  }

  /**
   Adds the `expiry` option.
   
   - Parameter value: Set the length in seconds to cache the file for.
   Valid range: 1...31536000
   */
  @discardableResult public func expiry(_ value: Int) -> Self {
    return appending(key: "expiry", value: value)
  }
  
  /**
   Adds the `expiry` option.
   
   - Parameter value: Set the maximum length (1 year) to cache the file for.
   */
  @discardableResult public func maxExpiry() -> Self {
    return appending(key: "expiry", value: "max")
  }

}
