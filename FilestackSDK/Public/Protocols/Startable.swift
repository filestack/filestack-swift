//
//  Startable.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 30/06/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import Foundation

/// The protocol any startable process must conform to.
@objc(FSStartable)
public protocol Startable {
    /// Starts this process.
    @discardableResult func start() -> Bool

    /// :nodoc:
    func uploadFiles()
}
