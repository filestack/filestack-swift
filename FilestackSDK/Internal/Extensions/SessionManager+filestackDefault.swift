//
//  SessionManager+filestackDefault.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/5/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Alamofire
import Foundation

extension SessionManager {
    class func filestackDefault() -> SessionManager {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = additionalHeaders
        return SessionManager(configuration: configuration)
    }

    private class var additionalHeaders: HTTPHeaders {
        var defaultHeaders = SessionManager.defaultHTTPHeaders
        defaultHeaders["User-Agent"] = "filestack-swift \(shortVersionString)"
        defaultHeaders["Filestack-Source"] = "Swift-\(shortVersionString)"
        return defaultHeaders
    }

    private class var shortVersionString: String {
        return BundleInfo.version ?? "0.0.0"
    }
}
