//
//  ProcessService.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/11/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import Alamofire


internal class ProcessService: NetworkingService {

    let sessionManager = SessionManager.filestackDefault()
    let baseURL = Config.processURL

    func buildURL(tasks: String? = nil, handle: String, security: Security? = nil) -> URL? {

        var url = baseURL

        if let tasks = tasks {
            url.appendPathComponent(tasks, isDirectory: false)
        }

        if let security = security {
            url.appendPathComponent("security=policy:\(security.encodedPolicy),signature:\(security.signature)",
                                    isDirectory: false)
        }

        url.appendPathComponent(handle, isDirectory: false)

        return url
    }

    func buildURL(tasks: String? = nil, externalURL: URL, key: String, security: Security? = nil) -> URL? {

        var url = baseURL

        url.appendPathComponent(key, isDirectory: false)

        if let tasks = tasks {
            url.appendPathComponent(tasks, isDirectory: false)
        }

        if let security = security {
            url.appendPathComponent("security=policy:\(security.encodedPolicy),signature:\(security.signature)",
                isDirectory: false)
        }

        url.appendPathComponent(externalURL.absoluteString, isDirectory: false)

        return url
    }
}
