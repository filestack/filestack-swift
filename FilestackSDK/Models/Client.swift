//
//  Client.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 28/06/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


/**
    Represents a client that allows communicating with the 
    [Filestack REST API](https://www.filestack.com/docs/rest-api).
 */
@objc(FSClient) public class Client: NSObject {


    // MARK: - Properties

    /// An API key obtained from the [Developer Portal](http://dev.filestack.com).
    public let apiKey: String

    /// A `Security` object. `nil` by default.
    public let security: Security?

    /// A `StorageLocation` object. `nil` by default.
    public let storage: StorageLocation?


    // MARK: - Lifecyle Functions

    /**
        The designated initializer.
     
        - SeeAlso: `Security`

        - Parameter apiKey: An API key obtained from the Developer Portal.
        - Parameter security: A `Security` object. `nil` by default.
        - Parameter storage: A `StorageLocation` object. `nil` by default.
     */
    public init(apiKey: String, security: Security? = nil, storage: StorageLocation? = nil) {

        self.apiKey = apiKey
        self.security = security
        self.storage = storage

        super.init()
    }


    // MARK: - Public Functions

    /**
        A `FileLink` object for a given Filestack handle.

        - Parameter handle: A Filestack handle.
     */
    public func fileLink(`for` handle: String) -> FileLink {

        return FileLink(handle: handle, apiKey: apiKey, security: security)
    }

    /**
        An `ImageTransform` object for a Filestack handle.

        - SeeAlso: `ImageTransform`

        - Parameter handle: A Filestack handle.
     */
    public func imageTransform(handle: String) -> ImageTransform {

        return ImageTransform(handle: handle, apiKey: apiKey, security: security)
    }

    /**
        An `ImageTransform` object for an external URL.
     
        - SeeAlso: `ImageTransform`

        - Parameter externalURL: An external URL.
     */
    public func imageTransform(externalURL: URL) -> ImageTransform {

        return ImageTransform(externalURL: externalURL, apiKey: apiKey, security: security)
    }

    /**
        Uploads a file directly to a given storage location (currently only S3 is supported.)

        - Parameter localURL: The URL of the local file to be uploaded.
        - Parameter storage: The storage location. Defaults to `s3`.
        - Parameter useIntelligentIngestionIfAvailable: Attempts to use Intelligent Ingestion
            for file uploading. Defaults to `true`.
        - Parameter queue: The queue on which the upload progress and completion handlers are 
            dispatched.
        - Parameter uploadProgress: Sets a closure to be called periodically during the lifecycle
            of the upload process as data is uploaded to the server. `nil` by default.
        - Parameter completionHandler: Adds a handler to be called once the upload has finished.
     */
    public func multiPartUpload(from localURL: URL,
                                storage: StorageLocation = .s3,
                                useIntelligentIngestionIfAvailable: Bool = true,
                                queue: DispatchQueue = .main,
                                uploadProgress: ((Progress) -> Void)? = nil,
                                completionHandler: @escaping (NetworkJSONResponse?) -> Void) {

        let mpu = MultipartUpload(at: localURL,
                                  queue: queue,
                                  uploadProgress: uploadProgress,
                                  completionHandler: completionHandler,
                                  partUploadConcurrency: 5,
                                  chunkUploadConcurrency: 8,
                                  apiKey: apiKey,
                                  storage: storage,
                                  security: security,
                                  useIntelligentIngestionIfAvailable: useIntelligentIngestionIfAvailable)

        mpu.uploadFile()
    }
}


public extension Client {

    // MARK: - CustomStringConvertible

    /// Returns a `String` representation of self.
    override var description: String {

        var components: [String] = []

        components.append("\(super.description)(")
        components.append("    apiKey: \(apiKey),")

        if let security = security {
            components.append("    security: \(attachedDescription(object: security))")
        }

        if let storage = storage {
            components.append("    storage: \(String(describing: storage))")
        }

        components.append(")")

        return components.joined(separator: "\n")
    }
}

