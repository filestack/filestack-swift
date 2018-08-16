//
//  URLMimeTypeTests.swift
//  FilestackSDKTests
//
//  Created by Ruben Nine on 7/18/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import XCTest
@testable import FilestackSDK


class URLMimeTypeTests: XCTestCase {

    func testJPGMimeType() {

        let localURL = URL(string: "file://SOME-URL/image.jpg")!

        XCTAssertEqual(localURL.mimeType, "image/jpeg")
    }

    func testTextMimeType() {

        let localURL = URL(string: "file://SOME-URL/document.txt")!

        XCTAssertEqual(localURL.mimeType, "text/plain")
    }

    func testUndefinedMimeType() {

        let localURL = URL(string: "file://SOME-URL/document")!

        XCTAssertNil(localURL.mimeType)
    }

}
