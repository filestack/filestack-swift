//
//  APIService.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/6/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

private let Shared = APIService()

final class APIService: NetworkingServiceWithBaseURL {
    // MARK: - Internal Properties

    let session = URLSession.filestack()
    let baseURL = Constants.apiURL

    static let shared = Shared
}

// MARK: - Internal Functions

extension APIService {
    func deleteRequest(handle: String,
                       path: String?,
                       parameters: [String: Any]?,
                       security: Security?) throws -> URLRequest? {
        let queryItems: [URLQueryItem]?

        if let parameters = parameters {
            queryItems = parametersToQueryItems(parameters: parameters)
        } else {
            queryItems = nil
        }

        guard let url = buildURL(handle: handle, path: path, queryItems: queryItems, security: security) else { return nil }

        var request = URLRequest(url: url)

        request.httpMethod = "DELETE"

        return request
    }

    func overwriteRequest(handle: String,
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
}
