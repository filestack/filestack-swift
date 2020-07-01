//
//  DeferredAdd.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 30/06/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import Foundation

/// The protocol any uploader that supports deferred adds must conform to.
///
/// - Important: This protocol is only available in Swift.
public protocol DeferredAdd {
    /// Adds items to be uploaded.
    ///
    /// - Parameter uploadables: An array of `Uploadable` items.
    @discardableResult func add(uploadables: [Uploadable]) -> Bool
}
