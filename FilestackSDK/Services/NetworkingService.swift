//
//  NetworkingService.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/6/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import Alamofire


internal protocol NetworkingService {

    var sessionManager: SessionManager { get }
    var baseURL: URL { get }

    func buildURL(handle: String?, path: String?, security: Security?) -> URL?
}

extension NetworkingService {

    func buildURL(handle: String? = nil, path: String? = nil, security: Security? = nil) -> URL? {

        var url = baseURL

        if let path = path {
            url.appendPathComponent(path)
        }

        if let handle = handle {
            url.appendPathComponent(handle)
        }

        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }

        if let security = security {
            urlComponents.queryItems = [
                URLQueryItem(name: "policy", value: security.encodedPolicy),
                URLQueryItem(name: "signature", value: security.signature)
            ]
        }

        return try? urlComponents.asURL()
    }

    func postRequest(url: URL, parameters: [String: Any]? = nil) -> DataRequest? {

        return sessionManager.request(url, method: .post, parameters: parameters)
    }
}
