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
  @discardableResult func appending(_ option: TaskOption) -> Self {
    options.append(option)
    return self
  }
}
