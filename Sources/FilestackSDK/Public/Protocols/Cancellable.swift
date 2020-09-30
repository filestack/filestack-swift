//
//  Cancellable.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 30/06/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import Foundation

/// The protocol any cancellable process must conform to.
@objc(FSCancellable)
public protocol Cancellable {
    /// Cancels this process.
    @discardableResult func cancel() -> Bool
}
