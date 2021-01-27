//
//  DownloadResponse.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/5/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

@available(*, deprecated, renamed: "DownloadResponse")
public typealias NetworkDownloadResponse = DownloadResponse

/// This object represents a network download response.
@objc(FSNetworkDownloadResponse)
public class DownloadResponse: NSObject {
    // MARK: - Public Properties

    /// The URL request sent to the server.
    @objc public let request: URLRequest?

    /// The server's response to the URL request.
    @objc public let response: HTTPURLResponse?

    /// The temporary destination URL of the data returned from the server.
    @objc public let temporaryURL: URL?

    /// The final destination URL of the data returned from the server if it was moved.
    @objc public let destinationURL: URL?

    /// Returns the associated error value if the result if it is a failure, `nil` otherwise.
    @objc public var error: Swift.Error?

    // MARK: - Lifecycle

    init(request: URLRequest?, response: URLResponse?, temporaryURL: URL?, destinationURL: URL?, error: Swift.Error?) {
        self.request = request
        self.response = response as? HTTPURLResponse
        self.temporaryURL = temporaryURL
        self.destinationURL = destinationURL
        self.error = error

        super.init()
    }
}

// MARK: - CustomStringConvertible Conformance

extension DownloadResponse {
    /// :nodoc:
    override public var description: String {
        return Tools.describe(subject: self)
    }
}
