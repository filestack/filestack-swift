//
//  Monitorizable.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 30/06/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import Foundation

/// The protocol any monitorizable process must conform to.
@objc(FSMonitorizable)
public protocol Monitorizable {
    /// Returns a `Progress` object that may be used to monitor or cancel this process.
    var progress: Progress { get }
}

