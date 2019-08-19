//
//  FileLink.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 03/07/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Alamofire
import Foundation

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
        cdnService.buildURL(handle: self.handle, security: self.security)!
    }()

    // MARK: - Lifecyle Functions

    internal init(handle: String, apiKey: String, security: Security? = nil) {
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
     - Parameter queue: The queue on which the downloadProgress and completion handlers are dispatched.
     - Parameter downloadProgress: Sets a closure to be called periodically during the lifecycle
     of the Request as data is read from the server. `nil` by default.
     - Parameter completionHandler: Adds a handler to be called once the request has finished.
     */
    public func getContent(parameters: [String: Any]? = nil,
                           queue: DispatchQueue? = .main,
                           downloadProgress: ((Progress) -> Void)? = nil,
                           completionHandler: @escaping (NetworkDataResponse) -> Void) {
        guard let request = cdnService.getDataRequest(handle: handle,
                                                      path: nil,
                                                      parameters: parameters,
                                                      security: security) else {
            return
        }

        if let downloadProgress = downloadProgress {
            if let queue = queue {
                request.downloadProgress(queue: queue, closure: downloadProgress)
            } else {
                request.downloadProgress(closure: downloadProgress)
            }
        }

        request.validate(statusCode: Config.validHTTPResponseCodes)

        request.responseData(queue: queue, completionHandler: { response in

            completionHandler(NetworkDataResponse(with: response))
        })
    }

    /**
     Gets the image tags associated to this `FileLink` as a JSON payload.

     - Parameter queue: The queue on which the completion handler is dispatched.
     - Parameter completionHandler: Adds a handler to be called once the request has finished.
     */
    public func getTags(queue: DispatchQueue? = .main,
                        completionHandler: @escaping (NetworkJSONResponse) -> Void) {
        guard let request = cdnService.getImageTaggingRequest(type: "tags", handle: handle, security: security) else {
            return
        }

        request.validate(statusCode: Config.validHTTPResponseCodes)

        request.responseJSON(queue: queue) { response in

            completionHandler(NetworkJSONResponse(with: response))
        }
    }

    /**
     Gets the safe for work status associated to this `FileLink` as a JSON payload.

     - Parameter queue: The queue on which the completion handler is dispatched.
     - Parameter completionHandler: Adds a handler to be called once the request has finished.
     */
    public func getSafeForWork(queue: DispatchQueue? = .main,
                               completionHandler: @escaping (NetworkJSONResponse) -> Void) {
        guard let request = cdnService.getImageTaggingRequest(type: "sfw", handle: handle, security: security) else {
            return
        }

        request.validate(statusCode: Config.validHTTPResponseCodes)

        request.responseJSON(queue: queue) { response in

            completionHandler(NetworkJSONResponse(with: response))
        }
    }

    /**
     Gets metadata associated to this `Filelink` as a JSON payload.

     - Parameter options: The options that should be included as part of the response.
     - Parameter queue: The queue on which the completion handler is dispatched.
     - Parameter completionHandler: Adds a handler to be called once the request has finished.
     */
    @objc public func getMetadata(options: MetadataOptions,
                                  queue: DispatchQueue? = .main,
                                  completionHandler: @escaping (NetworkJSONResponse) -> Void) {
        let optionQueryItems = options.toArray().map {
            URLQueryItem(name: $0.description, value: "true")
        }

        guard let url = apiService.buildURL(handle: handle,
                                            path: "file",
                                            extra: "metadata",
                                            queryItems: optionQueryItems,
                                            security: security),
            let request = apiService.request(url: url, method: .get) else {
            return
        }

        request.validate(statusCode: Config.validHTTPResponseCodes)

        request.responseJSON(queue: queue) { response in

            completionHandler(NetworkJSONResponse(with: response))
        }
    }

    /**
     Downloads the content associated to this `FileLink` to a destination URL.

     - Parameter destinationURL: The local URL where content should be saved.
     - Parameter parameters: Any query string parameters that should be added to the request.
     `nil` by default.
     - Parameter queue: The queue on which the downloadProgress and completion handlers are dispatched.
     - Parameter downloadProgress: Sets a closure to be called periodically during the lifecycle
     of the Request as data is read from the server. `nil` by default.
     - Parameter completionHandler: Adds a handler to be called once the request has finished.
     */
    public func download(destinationURL: URL,
                         parameters: [String: Any]? = nil,
                         queue: DispatchQueue? = .main,
                         downloadProgress: ((Progress) -> Void)? = nil,
                         completionHandler: @escaping (NetworkDownloadResponse) -> Void) {
        let downloadDestination: DownloadRequest.DownloadFileDestination = { _, _ in

            let downloadOptions: DownloadRequest.DownloadOptions = [
                .createIntermediateDirectories,
                .removePreviousFile,
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
            if let queue = queue {
                request.downloadProgress(queue: queue, closure: downloadProgress)
            } else {
                request.downloadProgress(closure: downloadProgress)
            }
        }

        request.validate(statusCode: Config.validHTTPResponseCodes)

        request.responseData(queue: queue, completionHandler: { response in

            completionHandler(NetworkDownloadResponse(with: response))
        })
    }

    /**
     Removes this `FileLink` from Filestack.

     - Note: Please ensure this `FileLink` object has the `security` property properly set up with a `Policy`
     that includes the `remove` permission.

     - Parameter parameters: Any query string parameters that should be added to the request.
     `nil` by default.
     - Parameter queue: The queue on which the completion handler is dispatched.
     - Parameter completionHandler: Adds a handler to be called once the request has finished.
     */
    public func delete(parameters: [String: Any]? = nil,
                       queue: DispatchQueue? = .main,
                       completionHandler: @escaping (NetworkDataResponse) -> Void) {
        guard let request = apiService.deleteRequest(handle: handle,
                                                     path: Config.filePath,
                                                     parameters: ensureAPIKey(parameters),
                                                     security: security) else {
            return
        }

        request.validate(statusCode: Config.validHTTPResponseCodes)

        request.responseData(queue: queue, completionHandler: { response in

            completionHandler(NetworkDataResponse(with: response))
        })
    }

    /**
     Overwrites this `FileLink` with a provided local file.

     - Note: Please ensure this `FileLink` object has the `security` property properly set up with a `Policy`
     that includes the `write` permission.

     - Parameter parameters: Any query string parameters that should be added to the request.
     `nil` by default.
     - Parameter fileURL: A local file that will replace the existing remote content.
     - Parameter queue: The queue on which the uploadProgress and completion handlers are dispatched.
     - Parameter uploadProgress: Sets a closure to be called periodically during the lifecycle
     of the Request as data is written on the server. `nil` by default.
     - Parameter completionHandler: Adds a handler to be called once the request has finished.
     */
    public func overwrite(parameters: [String: Any]? = nil,
                          fileURL: URL,
                          queue: DispatchQueue? = .main,
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
            if let queue = queue {
                request.uploadProgress(queue: queue, closure: uploadProgress)
            } else {
                request.uploadProgress(closure: uploadProgress)
            }
        }

        request.validate(statusCode: Config.validHTTPResponseCodes)

        request.responseData(queue: queue, completionHandler: { response in

            completionHandler(NetworkDataResponse(with: response))
        })
    }

    /**
     Overwrites this `FileLink` with a provided remote URL.

     - Note: Please ensure this `FileLink` object has the `security` property properly set up with a `Policy`
     that includes the `write` permission.

     - Parameter parameters: Any query string parameters that should be added to the request.
     `nil` by default.
     - Parameter queue: The queue on which the completion handler is dispatched.
     - Parameter remoteURL: A remote `URL` whose content will replace the existing remote content.
     - Parameter completionHandler: Adds a handler to be called once the request has finished.
     */
    public func overwrite(parameters: [String: Any]? = nil,
                          remoteURL: URL,
                          queue: DispatchQueue? = .main,
                          completionHandler: @escaping (NetworkDataResponse) -> Void) {
        guard let request = apiService.overwriteRequest(handle: handle,
                                                        path: Config.filePath,
                                                        parameters: parameters,
                                                        remoteURL: remoteURL,
                                                        security: security) else {
            return
        }

        request.validate(statusCode: Config.validHTTPResponseCodes)

        request.responseData(queue: queue, completionHandler: { response in

            completionHandler(NetworkDataResponse(with: response))
        })
    }

    /**
     Returns an `Transformable` corresponding to this `FileLink`.
     */
    public func transformable() -> Transformable {
        return Transformable(handles: [handle], apiKey: apiKey, security: security)
    }

    // MARK: - Private Functions

    private func ensureAPIKey(_ parameters: [String: Any]?) -> [String: Any] {
        guard var parameters = parameters else {
            return ["key": apiKey]
        }

        if parameters.keys.contains("key") == false {
            parameters["key"] = apiKey
        }

        return parameters
    }
}

public extension FileLink {
    // MARK: - CustomStringConvertible

    /// Returns a `String` representation of self.
    override var description: String {
        var components: [String] = []

        components.append("\(super.description)(")
        components.append("    apiKey: \(apiKey),")
        components.append("    handle: \(handle),")
        components.append("    url: \(url.absoluteString)")

        if let security = security {
            components.append("    security: \(attachedDescription(object: security))")
        }

        components.append(")")

        return components.joined(separator: "\n")
    }
}
