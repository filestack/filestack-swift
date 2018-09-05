//
//  BaseOperation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/19/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

class BaseOperation: Operation {
  
  // `isReady` property override boilerplate, as suggested by Apple
  private var _ready: Bool = false
  
  override var isReady: Bool {
    get {
      return _ready
    }
    set {
      if _ready == newValue { return }
      willChangeValue(forKey: "isReady")
      _ready = newValue
      didChangeValue(forKey: "isReady")
    }
  }
  
  // `isExecuting` property override boilerplate, as suggested by Apple
  private var _executing: Bool = false
  
  override var isExecuting: Bool {
    get {
      return _executing
    }
    set {
      if _executing == newValue { return }
      willChangeValue(forKey: "isExecuting")
      _executing = newValue
      didChangeValue(forKey: "isExecuting")
    }
  }
  
  // `isFinished` property override boilerplate, as suggested by Apple
  private var _finished: Bool = false
  
  override var isFinished: Bool {
    get {
      return _finished
    }
    set {
      if _finished == newValue { return }
      willChangeValue(forKey: "isFinished")
      _finished = newValue
      didChangeValue(forKey: "isFinished")
    }
  }
  
  // `isCancelled` property override boilerplate, as suggested by Apple
  private var _cancelled: Bool = false
  
  override var isCancelled: Bool {
    get {
      return _cancelled
    }
    set {
      if _cancelled == newValue { return }
      willChangeValue(forKey: "isCancelled")
      _cancelled = newValue
      didChangeValue(forKey: "isCancelled")
    }
  }
}
