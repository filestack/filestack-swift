//
//  NetworkDataResponse.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 04/07/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Alamofire
import Foundation

/**
 This object represents a network data response.
 */
@objc(FSNetworkDataResponse) public class NetworkDataResponse: NSObject {
    // MARK: - Properties

    /// The URL request sent to the server.
    @objc public let request: URLRequest?

    /// The server's response to the URL request.
    @objc public let response: HTTPURLResponse?

    /// The data returned by the server.
    @objc public let data: Data?

    /// Returns the associated error value if the result if it is a failure, `nil` otherwise.
    @objc public var error: Error?

    // MARK: - Lifecyle Functions

    internal init(with dataResponse: DataResponse<Data>) {
        request = dataResponse.request
        response = dataResponse.response
        data = dataResponse.data
        error = dataResponse.error

        super.init()
    }
}

extension NetworkDataResponse {
    // MARK: - CustomStringConvertible

    /// Returns a `String` representation of self.
    public override var description: String {
        return "(request: \(String(describing: request))," +
            "response: \(String(describing: response)), " +
            "data: \(String(describing: data)), " +
            "error: \(String(describing: error)))"
    }
}
