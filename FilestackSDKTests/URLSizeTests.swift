//
//  URLSizeTests.swift
//  FilestackSDKTests
//
//  Created by Ruben Nine on 7/18/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import XCTest
@testable import FilestackSDK


class URLSizeTests: XCTestCase {
    
    func testExistingLocalURLSize() {

        let localURL = Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "jpg")!

        XCTAssertEqual(localURL.size(), 200367)
    }

    func testUnexistingLocalURLSize() {

        let localURL = URL(string: "file://UNEXISTING-PATH/file.txt")!

        XCTAssertNil(localURL.size())
    }

}
