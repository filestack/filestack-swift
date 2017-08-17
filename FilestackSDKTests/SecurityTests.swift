//
//  SecurityTests.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 28/06/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import XCTest
import Arcane
@testable import FilestackSDK


class SecurityTests: XCTestCase {
    
    func testConvenienceInitializerWithPolicyAndAppSecret() {

        let policy = Seeds.Policies.basic

        var security: Security!
        XCTAssertNoThrow(security = try Security(policy: policy, appSecret: "MY-APP-SECRET"))

        var jsonData: Data!
        XCTAssertNoThrow(jsonData = try! policy.toJSON())

        XCTAssertEqual(security.encodedPolicy, jsonData.base64EncodedString())
        XCTAssertEqual(security.signature, HMAC.SHA256(security.encodedPolicy, key: "MY-APP-SECRET")!)
    }

    func testDefaultInitializer() {

        let security = Security(encodedPolicy: "ENCODED-POLICY", signature: "SIGNATURE")

        XCTAssertEqual(security.encodedPolicy, "ENCODED-POLICY")
        XCTAssertEqual(security.signature, "SIGNATURE")
    }
}
