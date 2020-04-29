//
//  UploadService.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/19/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Alamofire
import Foundation

final class UploadService: NetworkingService {
    static let sessionManager = SessionManager.filestackDefault
    static let baseURL = Constants.uploadURL

    static func upload(multipartFormData: @escaping (MultipartFormData) -> Void,
                       url: URL,
                       queue: DispatchQueue? = .main,
                       completionHandler: @escaping (NetworkJSONResponse) -> Void) {
        sessionManager.upload(multipartFormData: multipartFormData, to: url) { result in
            switch result {
            case let .success(request, _, _):
                request.responseJSON(queue: queue) { response in
                    let jsonResponse = NetworkJSONResponse(with: response)
                    completionHandler(jsonResponse)
                }
            case let .failure(error):
                let jsonResponse = NetworkJSONResponse(with: error)
                completionHandler(jsonResponse)
            }
        }
    }

    static func upload(data: Data,
                       to url: URLConvertible,
                       method: HTTPMethod,
                       headers: HTTPHeaders? = nil) -> UploadRequest {
        return sessionManager.upload(data, to: url, method: method, headers: headers)
    }
}
