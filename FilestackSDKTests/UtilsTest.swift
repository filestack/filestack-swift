//
//  UtilsTest.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 03/07/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import XCTest
@testable import FilestackSDK


class UtilsTest: XCTestCase {
        
    func testGetURLWithBaseURL() {

        let baseURL = URL(string: "https://foo.bar")!
        let outputURL = Utils.getURL(baseURL: baseURL)

        XCTAssertNotNil(outputURL)
        XCTAssertEqual(baseURL, outputURL!)
    }

    func testGetURLWithBaseAndHandleURL() {

        let outputURL = Utils.getURL(baseURL: URL(string: "https://foo.bar")!,
                                     handle: "SOME-HANDLE")

        XCTAssertNotNil(outputURL)
        XCTAssertEqual("https://foo.bar/SOME-HANDLE", outputURL!.absoluteString)
    }

    func testGetURLWithBasePathAndHandleURL() {

        let outputURL = Utils.getURL(baseURL: URL(string: "https://foo.bar")!,
                                     handle: "SOME-HANDLE",
                                     path: "some/path")

        XCTAssertNotNil(outputURL)
        XCTAssertEqual("https://foo.bar/some/path/SOME-HANDLE", outputURL!.absoluteString)
    }

    func testGetURLWithBasePathHandleAndSecurityURL() {

        let security = Seeds.Securities.basic

        let outputURL = Utils.getURL(baseURL: URL(string: "https://foo.bar")!,
                                     handle: "SOME-HANDLE",
                                     path: "some/path",
                                     security: security)

        XCTAssertNotNil(outputURL)

        XCTAssertEqual("https://foo.bar/some/path/" +
                       "security=policy:\(security.encodedPolicy),signature:\(security.signature)/" +
                       "SOME-HANDLE",
                       outputURL!.absoluteString)
    }
}
