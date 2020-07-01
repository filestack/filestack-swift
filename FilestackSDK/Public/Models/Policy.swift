//
//  Policy.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 28/06/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/// Represents a policy object.
///
/// See [Creating Policies](https://www.filestack.com/docs/security/creating-policies) for more information about
/// policies.
@objc(FSPolicy)
public class Policy: NSObject {
    // MARK: - Properties

    /// The expiration date for the policy.
    public let expiry: Date

    /// The calls that you allow this policy to make.
    ///
    /// - SeeAlso: `PolicyCall`
    public let call: PolicyCall?

    /// The unique file handle that you would like to access.
    public var handle: String?

    /// It is possible to create a subset of external URL domains that are allowed to be image/document sources for
    /// processing.filestackapi.com transformations.
    ///
    /// The URL parameter only applies to processing engine transformations and cannot be used to restrict uploads via
    /// the picker to specific domains for example. The filter is a regular expression that must match the input URL.
    /// The following is an example of a policy that restricts conversion requests to urls from wikimedia:
    ///
    /// ```
    /// {
    ///     "expiry":1577836800,
    ///     "call":["convert"],
    ///     "url":"https://upload\\.wikimedia\\.org/wikipedia/.*"
    /// }
    /// ```
    public var url: String?

    /// The maximum file size in bytes that can be stored by your request.
    public var maxSize: UInt?

    /// The minimum file size that can be stored by your request.
    public var minSize: UInt?

    /// For policies that store files, a Perl-like regular expression that must match the path that the files will be
    /// stored under.
    public var path: String?

    /// For policies that store files, a Perl-like regular expression that must match the container/bucket that the
    /// files will be stored under.
    public var container: String?

    // MARK: - Lifecycle

    /// Convenience initializer with expiry time.
    @objc public convenience init(expiry: Date) {
        self.init(expiry: expiry,
                  call: nil,
                  handle: nil,
                  url: nil,
                  maxSize: nil,
                  minSize: nil,
                  path: nil,
                  container: nil)
    }

    /// Convenience initializer with expiry time and call permissions.
    @objc public convenience init(expiry: Date, call: PolicyCall) {
        self.init(expiry: expiry,
                  call: call,
                  handle: nil,
                  url: nil,
                  maxSize: nil,
                  minSize: nil,
                  path: nil,
                  container: nil)
    }

    /// The designated initializer.
    @nonobjc public init(expiry: Date,
                         call: PolicyCall? = nil,
                         handle: String? = nil,
                         url: String? = nil,
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
}

// MARK: - Internal Functions

extension Policy {
    func toJSON() throws -> Data {
        let data = try JSONSerialization.data(withJSONObject: toDictionary(), options: .sortedKeys)

        return data
    }
}

// MARK: - Private Functions

private extension Policy {
    func toDictionary() -> [String: Any] {
        var dict = [String: Any]()

        dict["expiry"] = expiry.timeIntervalSince1970

        if let call = call {
            dict["call"] = call.toArray()
        }

        if let handle = handle {
            dict["handle"] = handle
        }

        if let url = url {
            dict["url"] = url
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

// MARK: - CustomStringConvertible Conformance

extension Policy {
    /// :nodoc:
    override public var description: String {
        return Tools.describe(subject: self)
    }
}
