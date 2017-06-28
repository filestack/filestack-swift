//
//  ClientTests.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 28/06/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import XCTest
@testable import FilestackSDK


class ClientTests: XCTestCase {
    
    func testInitializerWithApiKey() {

        let client = Client(apiKey: "MY-API-KEY")

        XCTAssertEqual(client.apiKey, "MY-API-KEY")
        XCTAssertEqual(client.security, nil)
    }

    func testInitializerWithApiKeyAndSecurity() {

        let security = Seeds.Securities.basic
        let client = Client(apiKey: "MY-OTHER-API-KEY", security: security)

        XCTAssertEqual(client.apiKey, "MY-OTHER-API-KEY")
        XCTAssertEqual(client.security, security)
    }
}
