//
//  NetworkJSONResponse.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/17/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import Alamofire


/**
    This object represents a network JSON response.
 */
@objc(FSNetworkJSONResponse) public class NetworkJSONResponse: NSObject {


    // MARK: - Properties

    /// The URL request sent to the server.
    public let request: URLRequest?

    /// The server's response to the URL request.
    public let response: HTTPURLResponse?

    /// The JSON returned by the server.
    public let json: [String: Any]?

    /// Returns the associated error value if the result if it is a failure, `nil` otherwise.
    public var error: Error?


    // MARK: - Lifecyle Functions

    internal init(with dataResponse: DataResponse<Any>) {

        self.request = dataResponse.request
        self.response = dataResponse.response

        if let data = dataResponse.data {
            self.json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
        } else {
            self.json = nil
        }

        self.error = dataResponse.error

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

extension NetworkJSONResponse {

    public override var description: String {

        return "(request: \(String(describing: request))," +
               "response: \(String(describing: response)), " +
               "json: \(String(describing: json)), " +
               "error: \(String(describing: error)))"
    }
}
