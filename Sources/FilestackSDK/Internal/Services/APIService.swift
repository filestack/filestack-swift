//
//  APIService.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/6/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Alamofire
import Foundation

private let Shared = APIService()

final class APIService: NetworkingServiceWithBaseURL {
    // MARK: - Internal Properties

    let sessionManager = SessionManager.filestack()
    let baseURL = Constants.apiURL

    static let shared = Shared
}

// MARK: - Internal Functions

extension APIService {
    func deleteRequest(handle: String,
                              path: String?,
                              parameters: [String: Any]?,
                              security: Security?) -> DataRequest? {
        guard let url = buildURL(handle: handle, path: path, security: security) else { return nil }

        return sessionManager.request(url, method: .delete, parameters: parameters)
    }

    func overwriteRequest(handle: String,
                                 path: String?,
                                 parameters _: [String: Any]?,
                                 fileURL: URL,
                                 security: Security?) -> UploadRequest? {
        guard let url = buildURL(handle: handle, path: path, security: security) else { return nil }

        return sessionManager.upload(fileURL, to: url)
    }

    func overwriteRequest(handle: String,
                                 path: String?,
                                 parameters: [String: Any]?,
                                 remoteURL: URL,
                                 security: Security?) -> DataRequest? {
        guard let url = buildURL(handle: handle, path: path, security: security) else { return nil }

        var parameters = parameters ?? [String: Any]()

        if !parameters.keys.contains("url") {
            parameters["url"] = remoteURL.absoluteString
        }

        return sessionManager.request(url, method: .post, parameters: parameters)
    }
}
