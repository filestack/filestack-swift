//
//  NetworkingServiceTest.swift
//  FilestackSDKTests
//
//  Created by Ruben Nine on 7/6/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import XCTest
@testable import FilestackSDK

class NetworkingServiceTest: XCTestCase {
    let services: [NetworkingService] = [APIService(), CDNService()]

    func testBuildURL() {
        for service in services {
            let outputURL = service.buildURL()
            let expectedURL = service.baseURL

            XCTAssertEqual(outputURL, expectedURL)
        }
    }

    func testBaseURLWithHandleURL() {
        for service in services {
            let outputURL = service.buildURL(handle: "SOME-HANDLE")

            XCTAssertEqual("\(service.baseURL.absoluteString)/SOME-HANDLE", outputURL?.absoluteString)
        }
    }

    func testGetURLWithBasePathAndHandleURL() {
        for service in services {
            let outputURL = service.buildURL(handle: "SOME-HANDLE", path: "some/path")

            XCTAssertEqual("\(service.baseURL.absoluteString)/some/path/SOME-HANDLE", outputURL?.absoluteString)
        }
    }

    func testGetURLWithBasePathHandleAndSecurityURL() {
        let security = Seeds.Securities.basic

        for service in services {
            let outputURL = service.buildURL(handle: "SOME-HANDLE", path: "some/path", security: security)

            XCTAssertEqual("\(service.baseURL.absoluteString)/some/path/SOME-HANDLE" +
                "?policy=\(security.encodedPolicy)&signature=\(security.signature)",
                           outputURL?.absoluteString)
        }
    }
}
