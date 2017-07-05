//
//  NetworkDownloadResponse.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/5/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


/**
    This object represents a network download response.
 */
@objc(FSNetworkDownloadResponse) public class NetworkDownloadResponse: NSObject {


    // MARK: - Properties

    /// The URL request sent to the server.
    public let request: URLRequest?

    /// The server's response to the URL request.
    public let response: HTTPURLResponse?

    /// The temporary destination URL of the data returned from the server.
    public let temporaryURL: URL?

    /// The final destination URL of the data returned from the server if it was moved.
    public let destinationURL: URL?

    /// Returns the associated error value if the result if it is a failure, `nil` otherwise.
    public var error: Error?


    // MARK: - Lifecyle Functions

    init(request: URLRequest? = nil,
         response: HTTPURLResponse? = nil,
         temporaryURL: URL? = nil,
         destinationURL: URL? = nil,
         error: Error? = nil) {

        self.request = request
        self.response = response
        self.temporaryURL = temporaryURL
        self.destinationURL = destinationURL
        self.error = error

        super.init()
    }
}

extension NetworkDownloadResponse {

    public override var description: String {

        return "(request: \(String(describing: request))," +
               "response: \(String(describing: response)), " +
               "temporaryURL: \(String(describing: temporaryURL)), " +
               "destinationURL: \(String(describing: destinationURL)), " +
               "error: \(String(describing: error)))"
    }
}
