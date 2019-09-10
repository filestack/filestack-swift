//
//  MultifileUpload+ObjC.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 10/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

extension MultifileUpload {
    /// Adds multiple local URLs to be uploaded.
    ///
    /// You should use this only before your upload starts.
    ///
    /// - Important:
    /// This function is made available especially for Objective-C SDK users, if you are using Swift, you may prefer
    /// using `add(uploadables:)` instead.
    @objc(addMultipleURLs:) public func add(uploadables: [NSURL]) -> Bool {
        return add(uploadables: uploadables.map { $0 as URL })
    }

    /// Adds multiple Data items to be uploaded.
    ///
    /// You should use this only before your upload starts.
    ///
    /// - Important:
    /// This function is made available especially for Objective-C SDK users, if you are using Swift, you may prefer
    /// using `add(uploadables:)` instead.
    @objc(addMultipleData:) public func add(uploadables: [NSData]) -> Bool {
        return add(uploadables: uploadables.map { $0 as Data })
    }
}
