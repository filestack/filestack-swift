//
//  UploadStatus.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 10/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

@available(*, deprecated, renamed: "UploadState")
public typealias UploadStatus = UploadState

/// Represents the current state of an upload.
@objc(FSUploadStatus)
public enum UploadState: UInt {
    /// Upload has not started.
    case notStarted
    /// Upload is currently in progress.
    case inProgress
    /// Upload has completed.
    case completed
    /// Upload was cancelled.
    case cancelled
    /// Upload failed.
    @available(*, deprecated, message: "Marked for removal in version 3.0.")
    case failed
}

// MARK: - CustomStringConvertible Conformance

extension UploadState: CustomStringConvertible {
    /// :nodoc:
    public var description: String {
        switch self {
        case .notStarted: return "notStarted"
        case .inProgress: return "inProgress"
        case .completed: return "completed"
        case .cancelled: return "cancelled"
        case .failed: return "failed"
        }
    }
}
