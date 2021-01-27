//
//  SessionManagerTests.swift
//  FilestackSDKTests
//
//  Created by Ruben Nine on 7/5/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import OHHTTPStubs
import OHHTTPStubsSwift
import XCTest
@testable import FilestackSDK

class SessionManagerTests: XCTestCase {
    override func tearDown() {
        super.tearDown()
        HTTPStubs.removeAllStubs()
    }

    func testFilestackDefaultCustomHTTPHeaders() {
        let session = URLSession.filestack()
        let requestURL = URL(string: "https://SOME-URL-HERE")!

        stub(condition: isScheme(requestURL.scheme!) && isHost(requestURL.host!)) { request in
            return HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }

        let task = session.dataTask(with: requestURL)
        let headers = task.currentRequest?.allHTTPHeaderFields!

        XCTAssertEqual(headers?["User-Agent"], "filestack-swift \(shortVersionString)")
        XCTAssertEqual(headers?["Filestack-Source"], "Swift-\(shortVersionString)")
    }
}

private extension SessionManagerTests {
    var shortVersionString: String {
        let url = Helpers.url(forResource: "VERSION", withExtension: nil, subdirectory: nil)!

        return String(data: try! Data(contentsOf: url), encoding: .utf8)!
            .trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    }
}
