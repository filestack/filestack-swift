//
//  FileLink.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 03/07/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import Alamofire


/**
    Represents a filelink object.

    See [Filestack Architecture Overview](https://www.filestack.com/docs/file-architecture) for 
    more information files.
 */
@objc(FSFileLink) public class FileLink: NSObject {


    // MARK: - Properties

    /// An API key obtained from the Developer Portal.
    public let apiKey: String

    /// A `Security` object. `nil` by default.
    public let security: Security?

    /// A Filestack Handle. `nil` by default.
    public let handle: String

    /// A Filestack CDN URL corresponding to this `FileLink`.
    public var url: URL {

        return Utils.getURL(baseURL: Config.cdnURL, handle: handle, security: security)!
    }


    // MARK: - Lifecyle Functions

    /**
        The designated initializer.

        - SeeAlso: `Security`

        - Parameter handle: A Filestack Handle.
        - Parameter apiKey: An API key obtained from the Developer Portal.
        - Parameter security: A `Security` object. `nil` by default.
     */
    public init(handle: String, apiKey: String, security: Security? = nil) {

        self.handle = handle
        self.apiKey = apiKey
        self.security = security

        super.init()
    }


    // MARK: - Public Functions


    /**
        Downloads the content associated to this `FileLink`.
     
        - Parameter parameters: TODO explain.
        - Parameter downloadProgress: Sets a closure to be called periodically during the lifecycle 
            of the Request as data is read from the server.
        - Parameter completionHandler: Adds a handler to be called once the request has finished.
     */
    public func getContent(parameters: [String: Any]? = nil,
                           downloadProgress: ((Progress) -> Void)? = nil,
                           completionHandler: @escaping (NetworkDataResponse) -> Void) {

        guard let request = defaultCDNService.getDataRequest(handle: handle,
                                                             path: nil,
                                                             parameters: parameters,
                                                             security: security) else {
            return
        }

        if let downloadProgress = downloadProgress {
            request.downloadProgress(closure: downloadProgress)
        }

        request.validate(statusCode: [200, 303, 304])

        request.responseData(completionHandler: { (response) in

            let networkResponse = NetworkDataResponse(
                request: response.request,
                response: response.response,
                data: response.data,
                error: response.error
            )
            
            completionHandler(networkResponse)
        })
    }
}
