//
//  UploadService.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/19/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import Alamofire


internal class UploadService: NetworkingService {
  
  let sessionManager = SessionManager.filestackDefault()
  let baseURL = Config.uploadURL
  
  func upload(multipartFormData: @escaping (MultipartFormData) -> Void,
              url: URL,
              queue: DispatchQueue? = .main,
              completionHandler: @escaping (NetworkJSONResponse) -> Void) {
    
    sessionManager.upload(multipartFormData: multipartFormData, to: url) { result in
      switch result {
      case .success(let request, _, _):
        
        request.responseJSON(queue: queue) { response in
          let jsonResponse = NetworkJSONResponse(with: response)
          completionHandler(jsonResponse)
        }
        
      case .failure(let error):
        
        let jsonResponse = NetworkJSONResponse(with: error)
        completionHandler(jsonResponse)
      }
    }
  }
  
  func upload(data: Data,
              to url: URLConvertible,
              method: HTTPMethod,
              headers: HTTPHeaders? = nil) -> UploadRequest {
    
    return sessionManager.upload(data, to: url, method: method, headers: headers)
  }
}
