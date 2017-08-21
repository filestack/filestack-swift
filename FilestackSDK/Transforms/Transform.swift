//
//  Transform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 21/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


internal typealias TaskOption = (key: String, value: Any?)
internal typealias Task = (name: String, options: [TaskOption]?)

/// :nodoc:
@objc(FSTransform) public class Transform: NSObject {

    internal var options = [TaskOption]()
    internal var name: String

    internal var task: Task {

        return Task(name: name, options: options)
    }

    internal init(name: String) {

        self.name = name
    }
}
