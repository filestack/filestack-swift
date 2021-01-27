//
//  NetworkingServiceWithBaseURL+buildURL.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 10/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

extension NetworkingServiceWithBaseURL {
    func buildURL(handle: String? = nil,
                  path: String? = nil,
                  extra: String? = nil,
                  queryItems: [URLQueryItem]? = nil,
                  security: Security? = nil) -> URL? {
        var url = baseURL

        if let path = path { url.appendPathComponent(path) }
        if let handle = handle { url.appendPathComponent(handle) }
        if let extra = extra { url.appendPathComponent(extra) }

        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }

        if let queryItems = queryItems {
            urlComponents.queryItems = queryItems
        }

        if let security = security {
            if urlComponents.queryItems == nil {
                urlComponents.queryItems = []
            }

            urlComponents.queryItems?.append(URLQueryItem(name: "policy", value: security.encodedPolicy))
            urlComponents.queryItems?.append(URLQueryItem(name: "signature", value: security.signature))
        }

        return urlComponents.url
    }

    func parametersToQueryItems(parameters: [String: Any]) -> [URLQueryItem] {
        return parameters.compactMap { URLQueryItem(name: $0.key, value: $0.value as? String) }
    }
}
