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
     Default initializer.

     - SeeAlso: `Security`

     - Parameter apiKey: An API key obtained from the Developer Portal.
     - Parameter security: A `Security` object. `nil` by default.
     */
    @objc public init(apiKey: String, security: Security? = nil) {
        self.apiKey = apiKey
        self.security = security
        storage = nil

        super.init()
    }

    /**
     Initializer with security and storage location.

     - SeeAlso: `Security`

     - Parameter apiKey: An API key obtained from the Developer Portal.
     - Parameter security: A `Security` object. `nil` by default.
     - Parameter storage: A `StorageLocation` object.
     */
    @objc public init(apiKey: String, security: Security? = nil, storage: StorageLocation) {
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
    @objc public func fileLink(for handle: String) -> FileLink {
        return FileLink(handle: handle, apiKey: apiKey, security: security)
    }

    /**
     A `Transformable` object for a Filestack handle.

     - SeeAlso: `Transformable`

     - Parameter handle: A Filestack handle.
     */
    @objc public func transformable(handle: String) -> Transformable {
        return Transformable(handles: [handle], apiKey: apiKey, security: security)
    }

    /**
     A `Transformable` object for an array of Filestack handles.

     - SeeAlso: `Transformable`

     - Parameter handles: An array of Filestack handles.
     */
    @objc public func transformable(handles: [String]) -> Transformable {
        return Transformable(handles: handles, apiKey: apiKey, security: security)
    }

    /**
     A `Transformable` object for an external URL.

     - SeeAlso: `Transformable`

     - Parameter externalURL: An external URL.
     */
    @objc public func transformable(externalURL: URL) -> Transformable {
        return Transformable(externalURLs: [externalURL], apiKey: apiKey, security: security)
    }

    /**
     A `Transformable` object for an array of external URLs.

     - SeeAlso: `Transformable`

     - Parameter externalURLs: An array of external URLs.
     */
    @objc public func transformable(externalURLs: [URL]) -> Transformable {
        return Transformable(externalURLs: externalURLs, apiKey: apiKey, security: security)
    }

    /// Uploads a single `Uploadable` to a given storage location.
    ///
    /// Currently the only storage location supported is Amazon S3.
    ///
    /// - Important:
    /// If your uploadable can not return a MIME type (e.g. when passing `Data` as the uploadable), you **must** pass
    /// a custom `UploadOptions` with custom `storeOptions` initialized with a `mimeType` that better represents your
    /// uploadable, otherwise `text/plain` will be assumed.
    ///
    /// - Parameter uploadable: An item to upload conforming to `Uploadable`.
    /// - Parameter options: A set of upload options (see `UploadOptions` for more information.)
    /// - Parameter queue: The queue on which the upload progress and completion handlers are dispatched.
    /// - Parameter uploadProgress: Sets a closure to be called periodically during the lifecycle
    /// of the upload process as data is uploaded to the server. `nil` by default.
    /// - Parameter completionHandler: Adds a handler to be called once the upload has finished.
    ///
    /// - Returns: A `MultipartUpload` object that allows monitoring progress, cancelling the upload request, etc.
    @discardableResult
    public func upload(using uploadable: Uploadable,
                       options: UploadOptions = .defaults,
                       queue: DispatchQueue = .main,
                       uploadProgress: ((Progress) -> Void)? = nil,
                       completionHandler: @escaping (NetworkJSONResponse) -> Void) -> MultipartUpload {
        let mpu = MultipartUpload(using: uploadable, options: options, queue: queue, apiKey: apiKey, security: security)

        mpu.uploadProgress = uploadProgress
        mpu.completionHandler = completionHandler

        if options.startImmediately {
            mpu.start()
        }

        return mpu
    }

    /// Uploads an array of `Uploadable` items to a given storage location.
    ///
    /// Currently the only storage location supported is Amazon S3.
    ///
    /// - Important:
    /// If your uploadables can not return a MIME type (e.g. when passing `Data` as the uploadable), you **must** pass
    /// a custom `UploadOptions` with custom `storeOptions` initialized with a `mimeType` that better represents your
    /// uploadables, otherwise `text/plain` will be assumed.
    ///
    /// - Parameter uploadables: An array of items to upload conforming to `Uploadable`. May be `nil` if you intend to
    /// add them later to the returned `MultifileUpload` object.
    /// - Parameter options: A set of upload options (see `UploadOptions` for more information.)
    /// - Parameter queue: The queue on which the upload progress and completion handlers are dispatched.
    /// - Parameter uploadProgress: Sets a closure to be called periodically during the lifecycle
    /// of the upload process as data is uploaded to the server. `nil` by default.
    /// - Parameter completionHandler: Adds a handler to be called once the upload has finished.
    ///
    /// - Returns: A `MultifileUpload` object that allows monitoring progress, cancelling the upload request, etc.
    @discardableResult
    public func upload(using uploadables: [Uploadable]? = nil,
                       options: UploadOptions = .defaults,
                       queue: DispatchQueue = .main,
                       uploadProgress: ((Progress) -> Void)? = nil,
                       completionHandler: @escaping ([NetworkJSONResponse]) -> Void) -> MultifileUpload {
        let mpu = MultifileUpload(using: uploadables, options: options, queue: queue, apiKey: apiKey, security: security)

        mpu.uploadProgress = uploadProgress
        mpu.completionHandler = completionHandler

        if options.startImmediately {
            mpu.start()
        }

        return mpu
    }
}
