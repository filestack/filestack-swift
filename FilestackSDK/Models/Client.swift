//
//  Client.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 28/06/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


/**
    Represents a client that allows communicating with the Filestack REST API.
 */
@objc(FSClient) public class Client: NSObject {

    /// An API key obtained from the Developer Portal.
    public let apiKey: String

    /// A `Security` object. `nil` by default.
    public let security: Security?

    /// A `StorageLocation` object. `nil` by default.
    public let storage: StorageLocation?


    /**
        Convenience initializer that takes an API key, and optionally a `Security` object.
     
        - SeeAlso: `Security`

        - Parameter apiKey: An API key obtained from the Developer Portal.
        - Parameter security: A `Security` object. `nil` by default.
     */
    public init(apiKey: String, security: Security? = nil, storage: StorageLocation? = nil) {

        self.apiKey = apiKey
        self.security = security
        self.storage = storage

        super.init()
    }
}
