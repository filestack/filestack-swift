//
//  SessionManager+filestackDefault.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/5/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Alamofire
import Foundation

private class BundleFinder {}

extension SessionManager {
    static func filestack(background: Bool = false) -> SessionManager {
        let configuration: URLSessionConfiguration

        if background {
            configuration = .background(withIdentifier: Bundle.main.bundleIdentifier!.appending(".background-session"))
        } else {
            configuration = .default
        }

        configuration.isDiscretionary = false
        configuration.shouldUseExtendedBackgroundIdleMode = true
        configuration.httpMaximumConnectionsPerHost = 20
        configuration.httpShouldUsePipelining = true
        configuration.httpAdditionalHeaders = customHTTPHeaders

        return SessionManager(configuration: configuration)
    }

    // MARK: - Private Functions

    private static var customHTTPHeaders: HTTPHeaders {
        var defaultHeaders = SessionManager.defaultHTTPHeaders

        defaultHeaders["User-Agent"] = "filestack-swift \(shortVersionString)"
        defaultHeaders["Filestack-Source"] = "Swift-\(shortVersionString)"

        return defaultHeaders
    }

    private static var shortVersionString: String {
        return Bundle(for: BundleFinder.self).infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }
}
