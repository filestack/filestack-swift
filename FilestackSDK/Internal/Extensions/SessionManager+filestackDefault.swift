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
    static var filestackDefault: SessionManager = {
        let bundleIdentifier = Bundle.main.bundleIdentifier!
        let configuration = URLSessionConfiguration.background(withIdentifier: bundleIdentifier)
        var defaultHeaders = SessionManager.defaultHTTPHeaders

        defaultHeaders["User-Agent"] = "filestack-swift \(shortVersionString)"
        defaultHeaders["Filestack-Source"] = "Swift-\(shortVersionString)"

        configuration.httpShouldUsePipelining = true
        configuration.httpAdditionalHeaders = defaultHeaders

        return SessionManager(configuration: configuration)
    }()

    // MARK: - Private Functions

    private class var shortVersionString: String {
        return Bundle(for: BundleFinder.self).infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }
}
