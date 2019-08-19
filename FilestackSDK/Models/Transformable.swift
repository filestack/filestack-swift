//
//  Transformable.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/10/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/**
 Represents an `Transformable` object.

 See [Image Transformations Overview](https://www.filestack.com/docs/image-transformations) for more information
 about image transformations.
 */
@objc(FSTransformable) public class Transformable: NSObject {
    // MARK: - Public Properties

    /// An API key obtained from the Developer Portal.
    public let apiKey: String

    /// A `Security` object. `nil` by default.
    public let security: Security?

    /// A Filestack Handle. `nil` by default.
    public var handle: String? {
        return handles?.first
    }

    /// An array of Filestack Handles. `nil` by deafult.
    public let handles: [String]?

    /// An external URL. `nil` by default.
    public let externalURL: URL?

    /// An URL corresponding to this image transform.
    public var url: URL {
        return computeURL()
    }

    // MARK: - Private Properties

    private var transformationTasks: [Task] = [Task]()

    // MARK: - Lifecyle Functions

    init(handles: [String], apiKey: String, security: Security? = nil) {
        self.handles = handles
        self.externalURL = nil
        self.apiKey = apiKey
        self.security = security

        super.init()
    }

    init(externalURL: URL, apiKey: String, security: Security? = nil) {
        self.handles = nil
        self.externalURL = externalURL
        self.apiKey = apiKey
        self.security = security

        super.init()
    }

    // MARK: - Public Functions

    /**
     Adds a new transformation to the transformation chain.

     - Parameter transform: The `Transform` to add.
     */
    @objc(add:) @discardableResult public func add(transform: Transform) -> Self {
        transformationTasks.append(transform.task)

        return self
    }

    /**
     Includes detailed information about the transformation request.
     */
    @discardableResult public func debug() -> Self {
        let task = Task(name: "debug", options: nil)

        transformationTasks.insert(task, at: 0)

        return self
    }

    /**
     Stores a copy of the transformation results to your preferred filestore.

     - Parameter options: An `StorageOptions` value.
     - Parameter base64Decode: Specify that you want the data to be first decoded from base64
     before being written to the file. For example, if you have base64 encoded image data,
     you can use this flag to first decode the data before writing the image file.
     - Parameter queue: The queue on which the completion handler is dispatched.
     - Parameter completionHandler: Adds a handler to be called once the request has finished.
     */
    @discardableResult public func store(using options: StorageOptions,
                                         base64Decode: Bool = false,
                                         queue: DispatchQueue? = .main,
                                         completionHandler: @escaping (FileLink?, NetworkJSONResponse) -> Void) -> Self {
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

        let task = Task(name: "store", options: taskOptions)

        transformationTasks.insert(task, at: 0)

        // Create and perform post request
        guard let request = processService.request(url: url, method: .post) else { return self }

        request.validate(statusCode: Config.validHTTPResponseCodes)

        request.responseJSON(queue: queue ?? .main) { response in
            let jsonResponse = NetworkJSONResponse(with: response)
            var fileLink: FileLink?

            if let json = jsonResponse.json,
                let urlString = json["url"] as? String,
                let url = URL(string: urlString) {
                fileLink = FileLink(handle: url.lastPathComponent, apiKey: self.apiKey, security: self.security)
            }

            completionHandler(fileLink, jsonResponse)

            return
        }

        return self
    }

    /**
     Stores a copy of the transformation results to your preferred filestore.

     - Parameter fileName: Change or set the filename for the converted file.
     - Parameter location: An `StorageLocation` value.
     - Parameter path: Where to store the file in your designated container. For S3, this is
     the key where the file will be stored at.
     - Parameter container: The name of the bucket or container to write files to.
     - Parameter region: S3 specific parameter. The name of the S3 region your bucket is located
     in. All regions except for `eu-central-1` (Frankfurt), `ap-south-1` (Mumbai),
     and `ap-northeast-2` (Seoul) will work.
     - Parameter access: An `StorageAccess` value.
     - Parameter base64Decode: Specify that you want the data to be first decoded from base64
     before being written to the file. For example, if you have base64 encoded image data,
     you can use this flag to first decode the data before writing the image file.
     - Parameter queue: The queue on which the completion handler is dispatched.
     - Parameter completionHandler: Adds a handler to be called once the request has finished.
     */
    @available(*, deprecated, message: "Use the new store(using:base64Decode:queue:completionHandler) instead")
    @discardableResult public func store(fileName: String? = nil,
                                         location: StorageLocation,
                                         path: String? = nil,
                                         container: String? = nil,
                                         region: String? = nil,
                                         access: StorageAccess,
                                         base64Decode: Bool,
                                         queue: DispatchQueue? = .main,
                                         completionHandler: @escaping (FileLink?, NetworkJSONResponse) -> Void) -> Self {
        let options = StorageOptions(location: location,
                                     region: region,
                                     container: container,
                                     path: path,
                                     filename: fileName,
                                     access: access)

        return store(using: options, base64Decode: base64Decode, queue: queue, completionHandler: completionHandler)
    }
}

private extension Transformable {
    func computeURL() -> URL {
        if let handles = handles {
            return processService.buildURL(tasks: tasksToURLFragment(), handles: handles, security: security)!
        } else {
            return processService.buildURL(tasks: tasksToURLFragment(), externalURL: externalURL!, key: apiKey, security: security)!
        }
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
