//
//  Error.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 03/07/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import Foundation

enum Error: Swift.Error {
    case cancelled
    case unknown
    case api(_ description: String)
    case custom(_ description: String)
}

extension Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .cancelled:
            return "The upload operation was cancelled by the user."
        case .unknown:
            return "Unknown error."
        case let .api(description):
            return "API Error: \(description)"
        case let .custom(description):
            return description
        }
    }
}
