//
//  ProcessService.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/11/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

private let Shared = ProcessService()

final class ProcessService: NetworkingServiceWithBaseURL {
    // MARK: - Internal Properties

    let session = URLSession.filestack()
    let baseURL = Constants.cdnURL

    static let shared = Shared
}

// MARK: - Internal Functions

extension ProcessService {
    func buildURL(tasks: String? = nil, sources: [String], key: String? = nil, security: Security? = nil) -> URL? {
        var url = baseURL

        if let key = key {
            url.appendPathComponent(key)
        }

        if let tasks = tasks {
            url.appendPathComponent(tasks)
        }

        if let security = security {
            url.appendPathComponent("security=policy:\(security.encodedPolicy),signature:\(security.signature)")
        }

        if sources.count == 1, let source = sources.first {
            // Most common case
            url.appendPathComponent(source)
        } else {
            url.appendPathComponent("[\(sources.joined(separator: ","))]")
        }

        return url
    }
}
