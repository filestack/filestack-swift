//
//  JSONResponse.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/17/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

@available(*, deprecated, renamed: "JSONResponse")
public typealias NetworkJSONResponse = JSONResponse

/// This object represents a network JSON response.
@objc(FSNetworkJSONResponse)
public class JSONResponse: NSObject {
    // MARK: - Public Properties

    /// The URL request sent to the server.
    @objc public let request: URLRequest?

    /// The server's response to the URL request.
    @objc public let response: HTTPURLResponse?

    /// The JSON returned by the server.
    @objc public let json: [String: Any]?

    /// Optionally, some associated context.
    @objc public let context: Any?

    /// Returns the associated error value if the result if it is a failure, `nil` otherwise.
    @objc public var error: Swift.Error?

    // MARK: - Lifecycle

    init(request: URLRequest? = nil, response: URLResponse? = nil, data: Data? = nil, error: Swift.Error?) {
        self.request = request
        self.response = response as? HTTPURLResponse

        if let data = data {
            self.json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
        } else {
            self.json = nil
        }

        self.error = error
        self.context = nil

        super.init()
    }

    init(response: JSONResponse, context: Any?) {
        self.request = response.request
        self.response = response.response
        self.json = response.json
        self.error = response.error
        self.context = context

        super.init()
    }
}

// MARK: - CustomStringConvertible Conformance

extension JSONResponse {
    /// :nodoc:
    override public var description: String {
        return Tools.describe(subject: self)
    }
}
