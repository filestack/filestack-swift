//
//  NetworkJSONResponse.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/17/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Alamofire
import Foundation

/**
 This object represents a network JSON response.
 */
@objc(FSNetworkJSONResponse) public class NetworkJSONResponse: NSObject {
    // MARK: - Properties

    /// The URL request sent to the server.
    @objc public let request: URLRequest?

    /// The server's response to the URL request.
    @objc public let response: HTTPURLResponse?

    /// The JSON returned by the server.
    @objc public let json: [String: Any]?

    /// Returns the associated error value if the result if it is a failure, `nil` otherwise.
    @objc public var error: Error?

    // MARK: - Lifecycle Functions

    internal init(with dataResponse: DataResponse<Any>) {
        request = dataResponse.request
        response = dataResponse.response

        if let data = dataResponse.data {
            json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
        } else {
            json = nil
        }

        error = dataResponse.error

        super.init()
    }

    internal init(with error: Error) {
        self.request = nil
        self.response = nil
        self.json = nil
        self.error = error

        super.init()
    }
}

// MARK: - CustomStringConvertible

extension NetworkJSONResponse {
    /// :nodoc:
    override public var description: String {
        return Tools.describe(subject: self)
    }
}
