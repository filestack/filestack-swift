//
//  NetworkDownloadResponse.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/5/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Alamofire
import Foundation

/**
 This object represents a network download response.
 */
@objc(FSNetworkDownloadResponse) public class NetworkDownloadResponse: NSObject {
    // MARK: - Properties

    /// The URL request sent to the server.
    @objc public let request: URLRequest?

    /// The server's response to the URL request.
    @objc public let response: HTTPURLResponse?

    /// The temporary destination URL of the data returned from the server.
    @objc public let temporaryURL: URL?

    /// The final destination URL of the data returned from the server if it was moved.
    @objc public let destinationURL: URL?

    /// Returns the associated error value if the result if it is a failure, `nil` otherwise.
    @objc public var error: Error?

    // MARK: - Lifecycle Functions

    internal init(with downloadResponse: DownloadResponse<Data>) {
        self.request = downloadResponse.request
        self.response = downloadResponse.response
        self.temporaryURL = downloadResponse.temporaryURL
        self.destinationURL = downloadResponse.destinationURL
        self.error = downloadResponse.error

        super.init()
    }
}

// MARK: - CustomStringConvertible

extension NetworkDownloadResponse {
    /// :nodoc:
    override public var description: String {
        return Tools.describe(subject: self)
    }
}
