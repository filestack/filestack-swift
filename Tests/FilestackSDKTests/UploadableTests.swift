//
//  UploadableTests.swift
//  FilestackSDKTests
//
//  Created by Ruben Nine on 10/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import XCTest

class UploadableTests: XCTestCase {
    // MARK: - URL Tests

    func testExistingLocalURLSize() {
        let localURL = Helpers.url(forResource: "sample", withExtension: "jpg", subdirectory: "Fixtures")!

        XCTAssertEqual(localURL.size, 200_367)
    }

    func testUnexistingLocalURLSize() {
        let localURL = URL(string: "file://UNEXISTING-PATH/file.txt")!

        XCTAssertNil(localURL.size)
    }

    func testJPGMimeTypeFromURL() {
        let localURL = URL(string: "file://SOME-URL/image.jpg")!

        XCTAssertEqual(localURL.mimeType, "image/jpeg")
    }

    func testTextMimeTypeFromURL() {
        let localURL = URL(string: "file://SOME-URL/document.txt")!

        XCTAssertEqual(localURL.mimeType, "text/plain")
    }

    func testUndefinedMimeTypeFromURL() {
        let localURL = URL(string: "file://SOME-URL/document")!

        XCTAssertNil(localURL.mimeType)
    }

    // MARK: - Data Tests

    func testEmptyDataSize() {
        let data = Data()

        XCTAssertEqual(data.size, 0)
    }

    func testNonEmptyDataSize() {
        let data = "12345".data(using: .utf8)!

        XCTAssertEqual(data.size, 5)
    }

    func testUndefinedMimeTypeFromData() {
        let data = Data()

        XCTAssertNil(data.mimeType)
    }
}
