//
//  FileLinkTests.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 03/07/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import XCTest
@testable import FilestackSDK


class FileLinkTests: XCTestCase {
        
    func testInitializerWithHandleAndApiKey() {

        let fileLink = FileLink(handle: "MY-HANDLE", apiKey: "MY-API-KEY")

        XCTAssertEqual(fileLink.handle, "MY-HANDLE")
        XCTAssertEqual(fileLink.apiKey, "MY-API-KEY")
        XCTAssertEqual(fileLink.security, nil)
    }

    func testInitializerWithHandleApiKeyAndSecurity() {

        let security = Seeds.Securities.basic
        let fileLink = FileLink(handle: "MY-HANDLE", apiKey: "MY-API-KEY", security: security)

        XCTAssertEqual(fileLink.handle, "MY-HANDLE")
        XCTAssertEqual(fileLink.apiKey, "MY-API-KEY")
        XCTAssertEqual(fileLink.security, security)
    }

    func testURL() {

        let fileLink = FileLink(handle: "MY-HANDLE", apiKey: "MY-API-KEY")
        let expectedURL = Config.cdnURL.appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(fileLink.url, expectedURL)
    }

    func testURLWithSecurity() {

        let security = Seeds.Securities.basic
        let fileLink = FileLink(handle: "MY-HANDLE", apiKey: "MY-API-KEY", security: security)

        let expectedURL = Config.cdnURL
            .appendingPathComponent(
                "security=policy:\(security.encodedPolicy)," +
                "signature:\(security.signature)"
            )
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(fileLink.url, expectedURL)
    }
}
