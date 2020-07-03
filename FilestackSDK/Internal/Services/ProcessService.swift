//
//  ProcessService.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/11/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Alamofire
import Foundation

final class ProcessService: NetworkingServiceWithBaseURL {
    static let sessionManager = SessionManager.filestack()
    static let baseURL = Constants.apiURL

    static func buildURL(tasks: String? = nil, sources: [String], key: String? = nil, security: Security? = nil) -> URL? {
        var url = baseURL

        if let key = key {
            url.appendPathComponent(key, isDirectory: false)
        }

        if let tasks = tasks {
            url.appendPathComponent(tasks, isDirectory: false)
        }

        if let security = security {
            url.appendPathComponent("security=policy:\(security.encodedPolicy),signature:\(security.signature)",
                                    isDirectory: false)
        }

        if sources.count == 1, let source = sources.first {
            // Most common case
            url.appendPathComponent(source, isDirectory: false)
        } else {
            url.appendPathComponent("[\((sources.map { $0 }).joined(separator: ","))]", isDirectory: false)
        }

        return url
    }
}
