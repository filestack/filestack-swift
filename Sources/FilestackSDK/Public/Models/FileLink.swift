//
//  FileLink.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 03/07/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/// Represents a `FileLink` object.
///
/// See [Filestack Architecture Overview](https://www.filestack.com/docs/file-architecture) for more information about
/// files.
@objc(FSFileLink)
public class FileLink: NSObject {
    // MARK: - Public Properties

    /// An API key obtained from the Developer Portal.
    public let apiKey: String

    /// A `Security` object. `nil` by default.
    public let security: Security?

    /// A Filestack Handle. `nil` by default.
    @objc public let handle: String

    /// A Filestack CDN URL corresponding to this `FileLink`.
    @objc public lazy var url: URL = {
        CDNService.shared.buildURL(handle: self.handle, security: self.security)!
    }()

    // MARK: - Lifecycle

    init(handle: String, apiKey: String, security: Security? = nil) {
        self.handle = handle
        self.apiKey = apiKey
        self.security = security

        super.init()
    }
}

// MARK: - Public Functions

public extension FileLink {
    /// Gets the content associated to this `FileLink` as a `Data` object.
    ///
    /// - Parameter parameters: Any query string parameters that should be added to the request.
    /// `nil` by default.
    /// - Parameter queue: The queue on which the downloadProgress and completion handlers are dispatched.
    /// - Parameter downloadProgress: Sets a closure to be called periodically during the lifecycle
    /// of the Request as data is read from the server. `nil` by default.
    /// - Parameter completionHandler: Adds a handler to be called once the request has finished.
    @objc func getContent(parameters: [String: Any]? = nil,
                          queue: DispatchQueue? = .main,
                          downloadProgress: ((Progress) -> Void)? = nil,
                          completionHandler: @escaping (DataResponse) -> Void) {
        guard let request = CDNService.shared.getRequest(handle: handle,
                                                         path: nil,
                                                         parameters: parameters,
                                                         security: security)
        else {
            return
        }

        var progressObservers: [NSKeyValueObservation] = []

        let task = CDNService.shared.session.dataTask(with: request) { (data, response, error) in
            progressObservers.removeAll()
            queue?.async {
                completionHandler(DataResponse(request: request, response: response, data: data, error: error))
            }
        }

        if let downloadProgress = downloadProgress {
            progressObservers.append(task.progress.observe(\.fractionCompleted) { progress, _ in
                queue?.async {
                    downloadProgress(progress)
                }
            })
        }

        task.resume()
    }

    /// Gets the image tags associated to this `FileLink` as a JSON payload.
    ///
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter completionHandler: Adds a handler to be called once the request has finished.
    @objc func getTags(queue: DispatchQueue? = .main,
                       completionHandler: @escaping (JSONResponse) -> Void) {
        guard let request = CDNService.shared.getImageTaggingRequest(type: "tags", handle: handle, security: security) else {
            return
        }

        let task = CDNService.shared.session.dataTask(with: request) { (data, response, error) in
            queue?.async {
                completionHandler(JSONResponse(request: request, response: response, data: data, error: error))
            }
        }

        task.resume()
    }

    /// Gets the safe for work status associated to this `FileLink` as a JSON payload.
    ///
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter completionHandler: Adds a handler to be called once the request has finished.
    @objc func getSafeForWork(queue: DispatchQueue? = .main,
                              completionHandler: @escaping (JSONResponse) -> Void) {
        guard let request = CDNService.shared.getImageTaggingRequest(type: "sfw", handle: handle, security: security) else {
            return
        }

        let task = CDNService.shared.session.dataTask(with: request) { (data, response, error) in
            queue?.async {
                completionHandler(JSONResponse(request: request, response: response, data: data, error: error))
            }
        }

        task.resume()
    }

    /// Gets metadata associated to this `Filelink` as a JSON payload.
    ///
    /// - Parameter options: The options that should be included as part of the response.
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter completionHandler: Adds a handler to be called once the request has finished.
    @objc func getMetadata(options: MetadataOptions,
                           queue: DispatchQueue? = .main,
                           completionHandler: @escaping (JSONResponse) -> Void) {
        let optionQueryItems = options.toArray().map {
            URLQueryItem(name: $0.description, value: "true")
        }

        guard let url = CDNService.shared.buildURL(handle: handle,
                                                   path: "file",
                                                   extra: "metadata",
                                                   queryItems: optionQueryItems,
                                                   security: security)
        else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let task = CDNService.shared.session.dataTask(with: request) { (data, response, error) in
            queue?.async {
                completionHandler(JSONResponse(request: request, response: response, data: data, error: error))
            }
        }

        task.resume()
    }

    /// Downloads the content associated to this `FileLink` to a destination URL.
    ///
    /// - Parameter destinationURL: The local URL where content should be saved.
    /// - Parameter parameters: Any query string parameters that should be added to the request.
    /// `nil` by default.
    /// - Parameter queue: The queue on which the downloadProgress and completion handlers are dispatched.
    /// - Parameter downloadProgress: Sets a closure to be called periodically during the lifecycle
    /// of the Request as data is read from the server. `nil` by default.
    /// - Parameter completionHandler: Adds a handler to be called once the request has finished.
    @objc func download(destinationURL: URL,
                        parameters: [String: Any]? = nil,
                        queue: DispatchQueue? = .main,
                        downloadProgress: ((Progress) -> Void)? = nil,
                        completionHandler: @escaping (DownloadResponse) -> Void) {
        guard let request = CDNService.shared.getRequest(handle: handle,
                                                         path: nil,
                                                         parameters: parameters,
                                                         security: security) else {
            return
        }

        var progressObservers: [NSKeyValueObservation] = []

        let task = CDNService.shared.session.downloadTask(with: request) { (url, response, error) in
            var destURL: URL? = nil
            var err = error

            if let url = url {
                do {
                    if FileManager.default.fileExists(atPath: destinationURL.path) {
                        try FileManager.default.removeItem(at: destinationURL)
                    }

                    try FileManager.default.moveItem(at: url, to: destinationURL)

                    destURL = destinationURL
                } catch {
                    err = error
                }
            }

            progressObservers.removeAll()

            queue?.async {
                completionHandler(
                    DownloadResponse(
                        request: request,
                        response: response,
                        temporaryURL: url,
                        destinationURL: destURL,
                        error: err
                    )
                )
            }
        }

        if let downloadProgress = downloadProgress {
            progressObservers.append(task.progress.observe(\.fractionCompleted) { progress, _ in
                queue?.async {
                    downloadProgress(progress)
                }
            })
        }

        task.resume()
    }

    /// Removes this `FileLink` from Filestack.
    ///
    /// - Note: Please ensure this `FileLink` object has the `security` property properly set up with a `Policy`
    /// that includes the `remove` permission.
    ///
    /// - Parameter parameters: Any query string parameters that should be added to the request.
    /// `nil` by default.
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter completionHandler: Adds a handler to be called once the request has finished.
    @objc func delete(parameters: [String: Any]? = nil,
                      queue: DispatchQueue? = .main,
                      completionHandler: @escaping (DataResponse) -> Void) {
        guard let request = try? APIService.shared.deleteRequest(handle: handle,
                                                            path: Constants.filePath,
                                                            parameters: ensureAPIKey(parameters),
                                                            security: security) else {
            return
        }

        let task = APIService.shared.session.dataTask(with: request) { (data, response, error) in
            completionHandler(DataResponse(request: request, response: response, data: data, error: error))
        }

        task.resume()
    }

    /// Overwrites this `FileLink` with a provided local file.
    ///
    /// - Note: Please ensure this `FileLink` object has the `security` property properly set up with a `Policy`
    /// that includes the `write` permission.
    ///
    /// - Parameter parameters: Any query string parameters that should be added to the request.
    /// `nil` by default.
    /// - Parameter fileURL: A local file that will replace the existing remote content.
    /// - Parameter queue: The queue on which the uploadProgress and completion handlers are dispatched.
    /// - Parameter uploadProgress: Sets a closure to be called periodically during the lifecycle
    /// of the Request as data is written on the server. `nil` by default.
    /// - Parameter completionHandler: Adds a handler to be called once the request has finished.
    @objc func overwrite(parameters: [String: Any]? = nil,
                         fileURL: URL,
                         queue: DispatchQueue? = .main,
                         uploadProgress: ((Progress) -> Void)? = nil,
                         completionHandler: @escaping (DataResponse) -> Void) {
        guard let request = APIService.shared.overwriteRequest(handle: handle,
                                                               path: Constants.filePath,
                                                               parameters: parameters,
                                                               security: security) else {
            return
        }

        var progressObservers: [NSKeyValueObservation] = []

        let task = APIService.shared.session.uploadTask(with: request, fromFile: fileURL) { (data, response, error) in
            progressObservers.removeAll()
            queue?.async {
                completionHandler(DataResponse(request: request, response: response, data: data, error: error))
            }
        }

        if let uploadProgress = uploadProgress {
            progressObservers.append(task.progress.observe(\.fractionCompleted) { progress, _ in
                queue?.async {
                    uploadProgress(progress)
                }
            })
        }

        task.resume()
    }

    /// Overwrites this `FileLink` with a provided remote URL.
    ///
    /// - Note: Please ensure this `FileLink` object has the `security` property properly set up with a `Policy`
    /// that includes the `write` permission.
    ///
    /// - Parameter parameters: Any query string parameters that should be added to the request.
    /// `nil` by default.
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter remoteURL: A remote `URL` whose content will replace the existing remote content.
    /// - Parameter completionHandler: Adds a handler to be called once the request has finished.
    @objc func overwrite(parameters: [String: Any]? = nil,
                         remoteURL: URL,
                         queue: DispatchQueue? = .main,
                         completionHandler: @escaping (DataResponse) -> Void) {
        var parameters = parameters ?? [String: Any]()

        if !parameters.keys.contains("url") {
            parameters["url"] = remoteURL.absoluteString
        }

        guard let request = APIService.shared.overwriteRequest(handle: handle,
                                                               path: Constants.filePath,
                                                               parameters: parameters,
                                                               security: security) else {
            return
        }

        let task = APIService.shared.session.dataTask(with: request) { (data, response, error) in
            queue?.async {
                completionHandler(DataResponse(request: request, response: response, data: data, error: error))
            }
        }

        task.resume()
    }

    /// Returns an `Transformable` corresponding to this `FileLink`.
    @objc func transformable() -> Transformable {
        return Transformable(handles: [handle], apiKey: apiKey, security: security)
    }
}

// MARK: - Private Functions

private extension FileLink {
    func ensureAPIKey(_ parameters: [String: Any]?) -> [String: Any] {
        guard var parameters = parameters else {
            return ["key": apiKey]
        }

        if !parameters.keys.contains("key") {
            parameters["key"] = apiKey
        }

        return parameters
    }
}

// MARK: - CustomStringConvertible Conformance

extension FileLink {
    /// :nodoc:
    override public var description: String {
        return Tools.describe(subject: self)
    }
}
