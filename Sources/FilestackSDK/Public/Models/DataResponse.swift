//
//  DataResponse.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 04/07/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

@available(*, deprecated, renamed: "DataResponse")
public typealias NetworkDataResponse = DataResponse

/// This object represents a network data response.
@objc(FSNetworkDataResponse)
public class DataResponse: NSObject {
    // MARK: - Public Properties

    /// The URL request sent to the server.
    @objc public let request: URLRequest?

    /// The server's response to the URL request.
    @objc public let response: HTTPURLResponse?

    /// The data returned by the server.
    @objc public let data: Data?

    /// Returns the associated error value if the result if it is a failure, `nil` otherwise.
    @objc public var error: Swift.Error?

    // MARK: - Lifecycle

    init(request: URLRequest?, response: URLResponse?, data: Data?, error: Swift.Error?) {
        self.request = request
        self.response = response as? HTTPURLResponse
        self.data = data
        self.error = error

        super.init()
    }
}

// MARK: - CustomStringConvertible Conformance

extension DataResponse {
    /// :nodoc:
    override public var description: String {
        return Tools.describe(subject: self)
    }
}
