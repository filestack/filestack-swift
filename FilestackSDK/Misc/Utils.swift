//
//  Utils.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 03/07/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


internal struct Utils {

    static func getURL(baseURL: URL,
                       handle: String? = nil,
                       path: String? = nil,
                       security: Security? = nil) -> URL? {

        var urlComponents: [String] = [baseURL.absoluteString]

        if let path = path {
            urlComponents.append(path)
        }

        if let security = security {
            urlComponents.append(
                "security=policy:\(security.encodedPolicy)," +
                "signature:\(security.signature)"
            )
        }

        if let handle = handle {
            urlComponents.append(handle)
        }

        let urlString = urlComponents.joined(separator: "/")
        let url = URL(string: urlString)

        return url
    }
}
