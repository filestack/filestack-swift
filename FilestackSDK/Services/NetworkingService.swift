//
//  NetworkingService.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 03/07/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import Alamofire


internal protocol NetworkingService {

    var baseURL: URL { get }

    var sessionManager: Alamofire.SessionManager { get }

    func getDataRequest(handle: String,
                        path: String?,
                        parameters: [String: Any]?,
                        security: Security?) -> DataRequest?
}

extension NetworkingService {

    func getDataRequest(handle: String,
                        path: String?,
                        parameters: [String: Any]?,
                        security: Security?) -> DataRequest? {

        guard let url = Utils.getURL(baseURL: baseURL,
                                     handle: handle,
                                     path: path,
                                     security: security) else {
            return nil
        }

        return sessionManager.request(url, method: .get, parameters: parameters)
    }

    func downloadRequest(handle: String,
                         path: String?,
                         parameters: [String: Any]?,
                         security: Security?,
                         downloadDestination: DownloadRequest.DownloadFileDestination?) -> DownloadRequest? {

        guard let url = Utils.getURL(baseURL: baseURL,
                                     handle: handle,
                                     path: path,
                                     security: security) else {
            return nil
        }

        return sessionManager.download(url, method: .get, parameters: parameters, to: downloadDestination)
    }
}
