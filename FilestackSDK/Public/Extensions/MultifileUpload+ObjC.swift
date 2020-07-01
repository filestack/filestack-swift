//
//  MultifileUpload+ObjC.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 10/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

// MARK: - Objective-C Compatibility

extension MultifileUpload {
    /// Adds multiple local URLs to be uploaded.
    ///
    /// - Important: Any items added after the upload process started will be ignored.
    ///
    /// - Note: This function is made available especially for Objective-C SDK users.
    /// If you are using Swift, you might want to use `add(uploadables:)` instead.
    ///
    /// - Parameter urls: An array of NSURL objects to upload.
    @objc public func add(urls: [NSURL]) -> Bool {
        return add(uploadables: urls.map { $0 as URL })
    }

    /// Adds multiple Data items to be uploaded.
    ///
    /// - Important: Any items added after the upload process started will be ignored.
    ///
    /// - Note: This function is made available especially for Objective-C SDK users.
    /// If you are using Swift, you might want to use `add(uploadables:)` instead.
    ///
    /// - Parameter multipleData: An array of NSData objects to upload.
    @objc public func add(multipleData: [NSData]) -> Bool {
        return add(uploadables: multipleData.map { $0 as Data })
    }
}
