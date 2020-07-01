//
//  Uploader.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 16/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

/// The protocol any uploader must conform to.
@objc(FSUploader)
public protocol Uploader: Monitorizable, Startable, Cancellable {
    /// Uploader UUID.
    var uuid: UUID { get }
    /// Current upload status.
    var currentStatus: UploadStatus { get }
}

// MARK: - Equatable Conformance

func ==(lhs: Uploader, rhs: Uploader) -> Bool {
    return lhs.uuid == rhs.uuid
}
