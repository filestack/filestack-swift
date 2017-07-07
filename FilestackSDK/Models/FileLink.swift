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
    Represents a `FileLink` object.

    See [Filestack Architecture Overview](https://www.filestack.com/docs/file-architecture) for more information
    about files.
 */
@objc(FSFileLink) public class FileLink: NSObject {


    // MARK: - Public Properties

    /// An API key obtained from the Developer Portal.
    public let apiKey: String

    /// A `Security` object. `nil` by default.
    public let security: Security?

    /// A Filestack Handle. `nil` by default.
    public let handle: String

    /// A Filestack CDN URL corresponding to this `FileLink`.
    public lazy var url: URL = {

        return cdnService.buildURL(handle: self.handle, security: self.security)!
    }()


    // MARK: - Private Properties

    private let validHTTPResponseCodes = Array(200..<300)


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
        Gets the content associated to this `FileLink` as a `Data` object.
     
        - Parameter parameters: Any query string parameters that should be added to the request.
             `nil` by default.
        - Parameter downloadProgress: Sets a closure to be called periodically during the lifecycle 
            of the Request as data is read from the server. `nil` by default.
        - Parameter completionHandler: Adds a handler to be called once the request has finished.
     */
    public func getContent(parameters: [String: Any]? = nil,
                           downloadProgress: ((Progress) -> Void)? = nil,
                           completionHandler: @escaping (NetworkDataResponse) -> Void) {

        guard let request = cdnService.getDataRequest(handle: handle,
                                                      path: nil,
                                                      parameters: parameters,
                                                      security: security) else {
            return
        }

        if let downloadProgress = downloadProgress {
            request.downloadProgress(closure: downloadProgress)
        }

        request.validate(statusCode: validHTTPResponseCodes)

        request.responseData(completionHandler: { (response) in

            completionHandler(NetworkDataResponse(with: response))
        })
    }

    /**
        Downloads the content associated to this `FileLink` to a destination URL.

        - Parameter destinationURL: The local URL where content should be saved.
        - Parameter parameters: Any query string parameters that should be added to the request.
            `nil` by default.
        - Parameter downloadProgress: Sets a closure to be called periodically during the lifecycle
            of the Request as data is read from the server. `nil` by default.
        - Parameter completionHandler: Adds a handler to be called once the request has finished.
     */
    public func download(destinationURL: URL,
                         parameters: [String: Any]? = nil,
                         downloadProgress: ((Progress) -> Void)? = nil,
                         completionHandler: @escaping (NetworkDownloadResponse) -> Void) {

        let downloadDestination: DownloadRequest.DownloadFileDestination = { (temporaryURL, response) in

            let downloadOptions: DownloadRequest.DownloadOptions = [
                .createIntermediateDirectories,
                .removePreviousFile
            ]

            return (destinationURL: destinationURL, options: downloadOptions)
        }

        guard let request = cdnService.downloadRequest(handle: handle,
                                                       path: nil,
                                                       parameters: parameters,
                                                       security: security,
                                                       downloadDestination: downloadDestination) else {
            return
        }

        if let downloadProgress = downloadProgress {
            request.downloadProgress(closure: downloadProgress)
        }

        request.validate(statusCode: validHTTPResponseCodes)

        request.responseData(completionHandler: { (response) in

            completionHandler(NetworkDownloadResponse(with: response))
        })
    }

    /**
        Removes this `FileLink` from Filestack.

        - Note: Please ensure this `FileLink` object has the `security` property properly set up with a `Policy`
          that includes the `remove` permission.

        - Parameter parameters: Any query string parameters that should be added to the request.
            `nil` by default.
        - Parameter completionHandler: Adds a handler to be called once the request has finished.
     */
    public func delete(parameters: [String: Any]? = nil,
                       completionHandler: @escaping (NetworkDataResponse) -> Void) {

        guard let request = apiService.deleteRequest(handle: handle,
                                                     path: Config.filePath,
                                                     parameters: parameters,
                                                     security: security) else {
            return
        }

        request.validate(statusCode: validHTTPResponseCodes)

        request.responseData(completionHandler: { (response) in

            completionHandler(NetworkDataResponse(with: response))
        })
    }

    /**
        Overwrites this `FileLink` with a provided local file.

        - Note: Please ensure this `FileLink` object has the `security` property properly set up with a `Policy`
        that includes the `remove` permission.

        - Parameter parameters: Any query string parameters that should be added to the request.
            `nil` by default.
        - Parameter uploadProgress: Sets a closure to be called periodically during the lifecycle
            of the Request as data is written on the server. `nil` by default.
        - Parameter completionHandler: Adds a handler to be called once the request has finished.
     */
    public func overwrite(parameters: [String: Any]? = nil,
                          fileURL: URL,
                          uploadProgress: ((Progress) -> Void)? = nil,
                          completionHandler: @escaping (NetworkDataResponse) -> Void) {

        guard let request = apiService.overwriteRequest(handle: handle,
                                                        path: Config.filePath,
                                                        parameters: parameters,
                                                        fileURL: fileURL,
                                                        security: security) else {
            return
        }

        if let uploadProgress = uploadProgress {
            request.uploadProgress(closure: uploadProgress)
        }

        request.validate(statusCode: validHTTPResponseCodes)

        request.responseData(completionHandler: { (response) in

            completionHandler(NetworkDataResponse(with: response))
        })
    }

    /**
        Overwrites this `FileLink` with a provided local file.

        - Note: Please ensure this `FileLink` object has the `security` property properly set up with a `Policy`
            that includes the `remove` permission.

        - Parameter parameters: Any query string parameters that should be added to the request.
            `nil` by default.
        - Parameter uploadProgress: Sets a closure to be called periodically during the lifecycle
            of the Request as data is written on the server. `nil` by default.
        - Parameter completionHandler: Adds a handler to be called once the request has finished.
     */
    public func overwrite(parameters: [String: Any]? = nil,
                          data: Data,
                          uploadProgress: ((Progress) -> Void)? = nil,
                          completionHandler: @escaping (NetworkDataResponse) -> Void) {

        guard let request = apiService.overwriteRequest(handle: handle,
                                                        path: Config.filePath,
                                                        parameters: parameters,
                                                        data: data,
                                                        security: security) else {
                                                            return
        }

        if let uploadProgress = uploadProgress {
            request.uploadProgress(closure: uploadProgress)
        }

        request.validate(statusCode: validHTTPResponseCodes)

        request.responseData(completionHandler: { (response) in

            completionHandler(NetworkDataResponse(with: response))
        })
    }
}
