//
//  CDNService.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 03/07/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

private let Shared = CDNService()

final class CDNService: NetworkingServiceWithBaseURL {
    // MARK: - Internal Properties

    let session = URLSession.filestack()
    let baseURL = Constants.cdnURL

    static let shared = Shared
}

// MARK: - Internal Functions

extension CDNService {
    func getRequest(handle: String,
                    path: String?,
                    parameters: [String: Any]?,
                    security: Security?) -> URLRequest? {
        let queryItems: [URLQueryItem]?

        if let parameters = parameters {
            queryItems = parametersToQueryItems(parameters: parameters)
        } else {
            queryItems = nil
        }

        guard let url = buildURL(handle: handle, path: path, queryItems: queryItems, security: security) else { return nil }

        var request = URLRequest(url: url)

        request.httpMethod = "GET"

        return request
    }

    func getImageTaggingRequest(type: String, handle: String, security: Security?) -> URLRequest? {
        var url = baseURL.appendingPathComponent(type)

        if let security = security {
            url.appendPathComponent("security=policy:\(security.encodedPolicy),signature:\(security.signature)")
        }

        url.appendPathComponent(handle)

        var request = URLRequest(url: url)

        request.httpMethod = "GET"

        return request
    }
}
