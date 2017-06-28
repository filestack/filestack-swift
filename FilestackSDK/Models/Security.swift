//
//  Security.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 28/06/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import SCrypto

/**
    Represents a security object.
 
    See [Security Overview](https://www.filestack.com/docs/security) for more information about security.
 */
class Security: NSObject {


    // MARK: - Properties

    /// An encoded policy.
    let encodedPolicy: String

    /// A computed signature.
    let signature: String


    // MARK: - Lifecyle Functions

    /**
        Convenience initializer that takes a `Policy` and an `appSecret` as parameters.
        
        - SeeAlso: `Policy`

        - Parameter policy: A configured `Policy` object.
        - Parameter appSecret: A secret taken from the developer portal.
    */
    convenience init(policy: Policy, appSecret: String) throws {

        let policyJSON: Data = try policy.toJSON()
        let encodedPolicy: String = policyJSON.base64EncodedString()
        let signature: String = "\(appSecret)\(encodedPolicy)".digest(.sha256)

        self.init(encodedPolicy: encodedPolicy, signature: signature)
    }


    /**
        The designated initializer.
     
        - SeeAlso: `init(policy:appSecret)`.
     
        - Parameter encodedPolicy: An encoded policy.
        - Parameter signature: A computed signature.
     */
    init(encodedPolicy: String, signature: String) {

        self.encodedPolicy = encodedPolicy
        self.signature = signature
    }
}
