//
//  BaseOperation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/19/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

class BaseOperation: Operation {
  
  enum State {
    case ready
    case executing
    case finished
    
    var key: String {
      switch self {
      case .ready:
        return "isReady"
      case .executing:
        return "isExecuting"
      case .finished:
        return "isFinished"
      }
    }
  }
  
  var state = State.ready {
    willSet {
      willChangeValue(forKey: state.key)
      willChangeValue(forKey: newValue.key)
    }
    didSet {
      didChangeValue(forKey: oldValue.key)
      didChangeValue(forKey: state.key)
    }
  }
  
  override var isReady: Bool {
    return state == .ready
  }
  
  override var isExecuting: Bool {
    return state == .executing
  }
  
  override var isFinished: Bool {
    return state == .finished
  }
}
