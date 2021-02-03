//
//  Transformable.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/10/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/// Represents an `Transformable` object.
///
/// See [Image Transformations Overview](https://www.filestack.com/docs/image-transformations) for more information
/// about image transformations.
public class Transformable: NSObject {
    // MARK: - Public Properties

    /// An API key obtained from the Developer Portal.
    @objc public let apiKey: String

    /// A `Security` object. `nil` by default.
    @objc public let security: Security?

    /// A Filestack Handle. `nil` by default.
    @objc public var handle: String? {
        return usingExternalURLs ? nil : sources.first
    }

    /// An array of Filestack Handles. `nil` by deafult.
    @objc public var handles: [String]? {
        return usingExternalURLs ? nil : sources
    }

    /// An external URL. `nil` by default.
    @objc public var externalURL: URL? {
        if usingExternalURLs, let source = sources.first {
            return URL(string: source)
        } else {
            return nil
        }
    }

    /// An array of external URLs. `nil` by default.
    @objc public var externalURLs: [URL]? {
        if usingExternalURLs {
            return sources.compactMap { URL(string: $0) }
        } else {
            return nil
        }
    }

    /// An URL corresponding to this image transform.
    @objc public var url: URL {
        return computeURL()
    }

    // MARK: - Private Properties

    private var transformationTasks: [Task] = [Task]()
    private var sources: [String]
    private var usingExternalURLs: Bool

    // MARK: - Lifecycle

    init(handles: [String], apiKey: String, security: Security? = nil) {
        self.sources = handles
        self.apiKey = apiKey
        self.security = security
        self.usingExternalURLs = false

        super.init()
    }

    init(externalURLs: [URL], apiKey: String, security: Security? = nil) {
        self.sources = externalURLs.map(\.absoluteString)
        self.apiKey = apiKey
        self.security = security
        self.usingExternalURLs = true

        super.init()
    }
}

// MARK: - Public Functions

public extension Transformable {
    /// Adds a new transformation to the transformation chain.
    ///
    /// - Parameter transform: The `Transform` to add.
    @discardableResult
    func add(transform: Transform) -> Self {
        transformationTasks.append(transform.task)

        return self
    }

    /// Includes detailed information about the transformation request.
    @objc
    @discardableResult
    func debug() -> Self {
        let task = Task(name: "debug", options: nil)

        transformationTasks.insert(task, at: 0)

        return self
    }

    /// Stores a copy of the transformation results to your preferred filestore.
    ///
    /// - Parameter options: An `StorageOptions` value.
    /// - Parameter base64Decode: Specify that you want the data to be first decoded from base64
    /// before being written to the file. For example, if you have base64 encoded image data,
    /// you can use this flag to first decode the data before writing the image file.
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter completionHandler: Adds a handler to be called once the request has finished.
    @objc
    @discardableResult
    func store(using options: StorageOptions,
               base64Decode: Bool = false,
               queue: DispatchQueue? = .main,
               completionHandler: @escaping (FileLink?, JSONResponse) -> Void) -> Self {
        // Setup task options
        var taskOptions = [TaskOption]()

        taskOptions.append((key: "location", value: options.location))

        if let region = options.region {
            taskOptions.append((key: "region", value: region))
        }

        if let container = options.container {
            taskOptions.append((key: "container", value: container))
        }

        if let path = options.path {
            taskOptions.append((key: "path", value: path))
        }

        if let filename = options.filename {
            taskOptions.append((key: "filename", value: filename))
        }

        taskOptions.append((key: "access", value: options.access))
        taskOptions.append((key: "base64decode", value: base64Decode))

        // Setup `store` task with task options.
        let storeTask = Task(name: "store", options: taskOptions)

        transformationTasks.insert(storeTask, at: 0)

        // Create request.
        var request = URLRequest(url: url)

        request.httpMethod = "GET"

        // Perform request.
        let task = ProcessService.shared.session.dataTask(with: request) { (data, response, error) in
            let jsonResponse = JSONResponse(request: request, response: response, data: data, error: error)

            var fileLink: FileLink?

            if let json = jsonResponse.json,
                let urlString = json["url"] as? String,
                let url = URL(string: urlString) {
                fileLink = FileLink(handle: url.lastPathComponent, apiKey: self.apiKey, security: self.security)
            }

            queue?.async {
                completionHandler(fileLink, jsonResponse)
            }
        }

        task.resume()

        return self
    }
}

// MARK: - Private Functions

private extension Transformable {
    func computeURL() -> URL {
        let key = usingExternalURLs ? apiKey : nil
        return ProcessService.shared.buildURL(tasks: tasksToURLFragment(), sources: sources, key: key, security: security)!
    }

    func sanitize(string: String) -> String {
        let allowedCharacters = CharacterSet(charactersIn: ",").inverted
        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacters)!
    }

    func tasksToURLFragment() -> String {
        let tasks: [String] = transformationTasks.map {
            if let options = $0.options {
                let params: [String] = options.map {
                    switch $0.value {
                    case let array as [Any]:
                        return "\($0.key):[\((array.map { String(describing: $0) }).joined(separator: ","))]"
                    default:
                        if let value = $0.value as? String {
                            return "\($0.key):\(sanitize(string: value))"
                        } else if let value = $0.value {
                            return "\($0.key):\(value)"
                        } else {
                            return $0.key
                        }
                    }
                }
                if !params.isEmpty {
                    return "\($0.name)=\(params.joined(separator: ","))"
                }
            }
            return $0.name
        }
        return tasks.joined(separator: "/")
    }
}

// MARK: - CustomStringConvertible Conformance

extension Transformable {
    /// :nodoc:
    override public var description: String {
        return Tools.describe(subject: self)
    }
}
