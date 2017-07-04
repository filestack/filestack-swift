//
//  NetworkDataResponse.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 04/07/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


/**
    This object represents a network data response.
 */
@objc(FSNetworkDataResponse) public class NetworkDataResponse: NSObject {


    // MARK: - Properties
    
    /// The URL request sent to the server.
    public let request: URLRequest?

    /// The server's response to the URL request.
    public let response: HTTPURLResponse?

    /// The data returned by the server.
    public let data: Data?

    /// Returns the associated error value if the result if it is a failure, `nil` otherwise.
    public var error: Error?


    // MARK: - Lifecyle Functions

    init(request: URLRequest? = nil,
         response: HTTPURLResponse? = nil,
         data: Data? = nil,
         error: Error? = nil) {

        self.request = request
        self.response = response
        self.data = data
        self.error = error

        super.init()
    }
}

extension NetworkDataResponse {

    public override var description: String {

        return "(request: \(String(describing: request))," +
               "response: \(String(describing: response)), " +
               "data: \(String(describing: data)), " +
               "error: \(String(describing: error)))"
    }
}
