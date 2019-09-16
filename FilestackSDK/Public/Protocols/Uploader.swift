//
//  Uploader.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 16/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

/// The protocol any monitorizable process must conform to.
@objc(FSMonitorizable) public protocol Monitorizable {
    /// Returns a `Progress` object that may be used to monitor or cancel this process.
    var progress: Progress { get }
}

/// The protocol any startable process must conform to.
@objc(FSStartable) public protocol Startable {
    /// Starts this process.
    @discardableResult func start() -> Bool

    /// :nodoc:
    @available(*, deprecated, message: "Marked for removal in version 3.0. Use start() instead.")
    func uploadFiles()
}

/// The protocol any cancellable process must conform to.
@objc(FSCancellable) public protocol Cancellable {
    /// Cancels this process.
    @discardableResult func cancel() -> Bool
}

/// The protocol any uploader must conform to.
@objc(FSUploader) public protocol Uploader: Monitorizable, Startable, Cancellable {
    /// Current upload status.
    var currentStatus: UploadStatus { get }
}

/// The protocol any uploader that supports deferred adds must conform to.
///
/// - Important: This protocol is only available in Swift.
public protocol DeferredAdd {
    /// Adds items to be uploaded.
    ///
    /// - Parameter uploadables: An array of `Uploadable` items.
    @discardableResult func add(uploadables: [Uploadable]) -> Bool
}
