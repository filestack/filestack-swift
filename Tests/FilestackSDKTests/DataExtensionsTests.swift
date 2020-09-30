//
//  DataExtensionsTests.swift
//  FilestackSDKTests
//
//  Created by Ruben Nine on 07/07/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import XCTest
@testable import FilestackSDK

class DataExtensionsTests: XCTestCase {

    func testMD5() throws {
        let data = String("foo").data(using: .utf8)!

        XCTAssertEqual(data.base64MD5Digest(), "rL0Y20zC+Fzt72VPzMSk2A==")
    }
}
