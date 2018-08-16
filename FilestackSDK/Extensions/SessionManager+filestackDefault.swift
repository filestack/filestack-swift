//
//  SessionManager+filestackDefault.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/5/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import Alamofire

extension SessionManager {
  
  class func filestackDefault() -> SessionManager {
    let configuration = URLSessionConfiguration.default
    configuration.httpAdditionalHeaders = additionalHeaders
    return SessionManager(configuration: configuration)
  }
  
  class private var additionalHeaders: HTTPHeaders {
    var defaultHeaders = SessionManager.defaultHTTPHeaders
    defaultHeaders["User-Agent"] = "filestack-swift \(shortVersionString)"
    defaultHeaders["Filestack-Source"] = "Swift-\(shortVersionString)"
    return defaultHeaders
  }
  
  class private var shortVersionString: String {
    return BundleInfo.version ?? "0.0.0"
  }
}
