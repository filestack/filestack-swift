//
//  SecurityTests.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 28/06/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import XCTest
@testable import FilestackSDK

class SecurityTests: XCTestCase {
    func testConvenienceInitializerWithPolicyAndAppSecret() {
        let policy = Seeds.Policies.basic

        var security: Security!
        XCTAssertNoThrow(security = try Security(policy: policy, appSecret: "MY-APP-SECRET"))

        var jsonData: Data!
        XCTAssertNoThrow(jsonData = try! policy.toJSON())

        XCTAssertEqual(security.encodedPolicy, jsonData.base64EncodedString())

        let signature: String = try! HMAC(key: "MY-APP-SECRET", variant: .sha256)
            .authenticate(Array(security.encodedPolicy.utf8))
            .toHexString()

        XCTAssertEqual(security.signature, signature)
    }

    func testDefaultInitializer() {
        let security = Security(encodedPolicy: "ENCODED-POLICY", signature: "SIGNATURE")

        XCTAssertEqual(security.encodedPolicy, "ENCODED-POLICY")
        XCTAssertEqual(security.signature, "SIGNATURE")
    }
}
