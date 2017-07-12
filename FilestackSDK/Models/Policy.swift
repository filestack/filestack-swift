//
//  Policy.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 28/06/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


/**
    Represents a policy object.
    
    See [Creating Policies](https://www.filestack.com/docs/security/creating-policies) for more 
    information about policies.
 */
@objc(FSPolicy) public class Policy: NSObject {


    // MARK: - Properties

    public let expiry: Date
    public let call: [PolicyCall]?
    public let handle: String?
    public let url: URL?
    public let maxSize: UInt?
    public let minSize: UInt?
    public let path: String?
    public let container: String?


    // MARK: - Lifecyle Functions

    /**
        The designated initializer.
     
        - Parameter expiry: The expiration date for the policy.
        - Parameter call: The calls that you allow this policy to make.
        - Parameter handle: The unique file handle that you would like to access.
        - Parameter url: It is possible to create a subset of external URL domains that are 
            allowed to be image/document sources for `processing.filestackapi.com` transformations.
        - Parameter maxSize: The maximum file size in bytes that can be stored by your request.
        - Parameter minSize: The minimum file size that can be stored by your request.
        - Parameter path: For policies that store files, a Perl-like regular expression that must 
            match the path that the files will be stored under.
        - Parameter container: For policies that store files, a Perl-like regular expression that 
            must match the container/bucket that the files will be stored under.
     */
    public init(expiry: Date,
         call: [PolicyCall]? = nil,
         handle: String? = nil,
         url: URL? = nil,
         maxSize: UInt? = nil,
         minSize: UInt? = nil,
         path: String? = nil,
         container: String? = nil) {

        self.expiry = expiry
        self.call = call
        self.handle = handle
        self.url = url
        self.maxSize = maxSize
        self.minSize = minSize
        self.path = path
        self.container = container
    }


    // MARK: - Internal Functions

    internal func toJSON() throws -> Data {

        let data = try JSONSerialization.data(withJSONObject: self.toDictionary())

        return data
    }


    // MARK: - Private Functions

    private func toDictionary() -> [String: Any] {

        var dict = [String: Any]()

        dict["expiry"] = expiry.timeIntervalSince1970

        if let call = call {
            dict["call"] = call.map { String(describing: $0) }
        }

        if let handle = handle {
            dict["handle"] = handle
        }

        if let url = url {
            dict["url"] = url.absoluteString
        }

        if let maxSize = maxSize {
            dict["max_size"] = maxSize
        }

        if let minSize = minSize {
            dict["min_size"] = minSize
        }

        if let path = path {
            dict["path"] = path
        }

        if let container = container {
            dict["container"] = container
        }

        return dict
    }
}


// MARK: - CustomStringConvertible

public extension Policy {

    override var description: String {

        var components: [String] = []

        components.append("\(super.description)(")
        components.append("    expiry: \(expiry),")

        if let call = call {
            components.append("    call: \(call)")
        }

        if let handle = handle {
            components.append("    handle: \(handle)")
        }

        if let url = url {
            components.append("    url: \(url)")
        }

        if let maxSize = maxSize {
            components.append("    maxSize: \(maxSize)")
        }

        if let minSize = minSize {
            components.append("    minSize: \(minSize)")
        }

        if let path = path {
            components.append("    path: \(path)")
        }

        if let container = container {
            components.append("    container: \(container)")
        }

        components.append(")")

        return components.joined(separator: "\n")
    }
}
