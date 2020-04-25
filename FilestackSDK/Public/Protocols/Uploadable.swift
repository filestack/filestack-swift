//
//  Uploadable.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 10/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

/// The protocol any uploadables must conform to.
public protocol Uploadable {
    /// The fileName of this uploadable, or `nil` if unavailable.
    var filename: String? { get }
    /// The size of this uploadable in bytes, or `nil` if unavailable.
    var size: UInt64? { get }
    /// The MIME type of this uploadable, or `nil` if unavailable.
    var mimeType: String? { get }
}
