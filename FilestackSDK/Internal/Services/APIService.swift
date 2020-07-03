//
//  APIService.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/6/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Alamofire
import Foundation

final class APIService: NetworkingServiceWithBaseURL {
    static let sessionManager = SessionManager.filestack()
    static let baseURL = Constants.apiURL

    static func deleteRequest(handle: String,
                              path: String?,
                              parameters: [String: Any]?,
                              security: Security?) -> DataRequest? {
        guard let url = buildURL(handle: handle, path: path, security: security) else { return nil }

        return sessionManager.request(url, method: .delete, parameters: parameters)
    }

    static func overwriteRequest(handle: String,
                                 path: String?,
                                 parameters _: [String: Any]?,
                                 fileURL: URL,
                                 security: Security?) -> UploadRequest? {
        guard let url = buildURL(handle: handle, path: path, security: security) else { return nil }

        return sessionManager.upload(fileURL, to: url)
    }

    static func overwriteRequest(handle: String,
                                 path: String?,
                                 parameters: [String: Any]?,
                                 remoteURL: URL,
                                 security: Security?) -> DataRequest? {
        guard let url = buildURL(handle: handle, path: path, security: security) else { return nil }

        var parameters = parameters ?? [String: Any]()

        if parameters.keys.contains("url") == false {
            parameters["url"] = remoteURL.absoluteString
        }

        return sessionManager.request(url, method: .post, parameters: parameters)
    }
}
