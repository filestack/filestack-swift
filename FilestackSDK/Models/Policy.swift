//
//  Policy.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 28/06/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


/**
    Represents a type of policy call.
 
    See [Creating Policies](https://www.filestack.com/docs/security/creating-policies) for more information about policy calls.
 */
@objc(FPCallPolicy) enum CallPolicy: UInt {

    /// Allows users to upload files.
    case pick = 0

    /// Allows files to be viewed/accessed.
    case read

    /// Allows metadata about files to be retrieved.
    case stat

    /// Allows use of the write function.
    case write

    /// Allows use of the writeUrl function.
    case writeURL

    /// Allows files to be written to custom storage.
    case store

    /// Allows transformation (crop, resize, rotate) of files, also needed for the viewer.
    case convert

    /// Allows removal of Filestack files.
    case remove

    /// Allows exif metadata to be accessed
    case exif


    /**
        Returns a `String` representation of self.
     */
    internal var toString: String {

        switch self {
        case .pick:

            return "pick"

        case .read:

            return "read"

        case .stat:

            return "stat"

        case .write:

            return "write"

        case .writeURL:

            return "write_url"

        case .store:

            return "store"

        case .convert:

            return "convert"

        case .remove:

            return "remove"

        case .exif:

            return "exif"
        }
    }
}

/**
    Represents a policy object.
    
    See [Creating Policies](https://www.filestack.com/docs/security/creating-policies) for more information about policies.
 */
@objc(FPPolicy) class Policy: NSObject {


    // MARK: - Properties

    private let expiry: Date
    private let call: [CallPolicy]
    private let handle: String
    private let url: URL
    private let maxSize: UInt
    private let minSize: UInt
    private let path: String
    private let container: String


    // MARK: - Lifecyle Functions


    /**
        Initializes a `Policy` object.
     
        - Parameter expiry: The expiration date for the policy.
        - Parameter call: The calls that you allow this policy to make.
        - Parameter handle: The unique file handle that you would like to access.
        - Parameter url: It is possible to create a subset of external URL domains that are allowed to be image/document sources for `processing.filestackapi.com` transformations. The URL parameter only applies to processing engine transformations and cannot be used to restrict uploads via the picker to specific domains for example. The filter is a regular expression that must match the input URL.
        - Parameter maxSize: The maximum file size in bytes that can be stored by your request. This only applies to the store command.
        - Parameter minSize: The minimum file size that can be stored by your request. This only applies to the store command. Together with maxSize, this forms a range. The value of minSize should be smaller then maxSize.
        - Parameter path: For policies that store files, a Perl-like regular expression that must match the path that the files will be stored under.
        - Parameter container: For policies that store files, a Perl-like regular expression that must match the container/bucket that the files will be stored under.
     */
    init(expiry: Date,
         call: [CallPolicy],
         handle: String,
         url: URL,
         maxSize: UInt,
         minSize: UInt,
         path: String,
         container: String) {

        self.expiry = expiry
        self.call = call
        self.handle = handle
        self.url = url
        self.maxSize = maxSize
        self.minSize = minSize
        self.path = path
        self.container = container
    }


    // MARK: - Public Functions

    /**
        Returns a JSON representation of this `Policy` object.
     
        - Returns: A `Data` object.
    */
    func toJSON() throws -> Data {

        let data = try JSONSerialization.data(withJSONObject: self.toDictionary())

        return data
    }


    // MARK: - Private Functions

    private func toDictionary() -> [String: Any] {

        var dict = [String: Any]()

        dict["expiry"] = expiry.timeIntervalSince1970
        dict["call"] = call.map { $0.toString }
        dict["handle"] = handle
        dict["url"] = url.absoluteString
        dict["max_size"] = maxSize
        dict["min_size"] = minSize
        dict["path"] = path
        dict["container"] = container

        return dict
    }
}
