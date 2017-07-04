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

        return Alamofire.request(url, method: .get, parameters: parameters)
    }
}
