//
//  SessionManagerTests.swift
//  FilestackSDKTests
//
//  Created by Ruben Nine on 7/5/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import XCTest
import OHHTTPStubs
@testable import Alamofire
@testable import FilestackSDK


class SessionManagerTests: XCTestCase {

    override func tearDown() {

        super.tearDown()
        OHHTTPStubs.removeAllStubs()
    }

    func testFilestackDefaultCustomHTTPHeaders() {

        let session = SessionManager.filestackDefault()
        let requestURL = URL(string: "https://SOME-URL-HERE")!
        let expectation = self.expectation(description: "request should succeed")
        var dataRequest: URLRequest?

        stub(condition: isScheme(requestURL.scheme!) && isHost(requestURL.host!)) { req in

            dataRequest = req
            expectation.fulfill()

            let data = Data()
            let stubsResponse = OHHTTPStubsResponse(data: data, statusCode: 200, headers: nil)

            return stubsResponse
        }

        let request = session.request(requestURL, method: .get)
        request.responseData { _ in }

        waitForExpectations(timeout: 5, handler: nil)

        let shortVersionString = BundleInfo.version!

        XCTAssertEqual(dataRequest?.value(forHTTPHeaderField: "User-Agent"), "filestack-swift \(shortVersionString)")
        XCTAssertEqual(dataRequest?.value(forHTTPHeaderField: "Filestack-Source"), "Swift-\(shortVersionString)")
    }
}
