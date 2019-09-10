//
//  UploadStatus.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 10/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

@objc(FSUploadStatus) public enum UploadStatus: UInt, CustomStringConvertible {
    /// Not started
    case notStarted

    /// In progress
    case inProgress

    /// Completed
    case completed

    /// Cancelled
    case cancelled

    /// Failed
    case failed

    // MARK: - CustomStringConvertible

    /// Returns a `String` representation of self.
    public var description: String {
        switch self {
        case .notStarted:
            return "notStarted"
        case .inProgress:
            return "public"
        case .completed:
            return "completed"
        case .cancelled:
            return "cancelled"
        case .failed:
            return "failed"
        }
    }
}
