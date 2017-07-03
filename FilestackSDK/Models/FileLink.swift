//
//  FileLink.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 03/07/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


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

    /// A Filestack CDN URL.
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


}
