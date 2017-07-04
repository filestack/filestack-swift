//
//  FileLinkTests.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 03/07/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import XCTest
import OHHTTPStubs
import CFNetwork.CFNetworkErrors

@testable import FilestackSDK
@testable import Alamofire


class FileLinkTests: XCTestCase {

    private let cdnStubConditions = isScheme(Config.cdnURL.scheme!) && isHost(Config.cdnURL.host!)

    override func tearDown() {

        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

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

    func testGetExistingContent() {

        stub(condition: cdnStubConditions) { _ in
            let stubPath = OHPathForFile("sample.jpg", type(of: self))!

            let httpHeaders: [AnyHashable: Any] = [
                "Content-Type": "image/jpeg",
                "Content-Length": "200367"
            ]

            return fixture(filePath: stubPath, headers: httpHeaders)
        }

        let security = Seeds.Securities.basic
        let fileLink = FileLink(handle: "MY-HANDLE", apiKey: "MY-API-KEY", security: security)

        let expectedRequestURL = Config.cdnURL
            .appendingPathComponent(
                "security=policy:\(security.encodedPolicy)," +
                "signature:\(security.signature)"
            )
            .appendingPathComponent("MY-HANDLE")

        let expectation = self.expectation(description: "request should succeed")

        fileLink.getContent() { (response) in

            XCTAssertEqual(response.response?.statusCode, 200)
            XCTAssertNotNil(response.response)
            XCTAssertEqual(response.response?.url, expectedRequestURL)
            XCTAssertNotNil(response.data)
            XCTAssertEqual(response.data?.count, 200367)
            XCTAssertNil(response.error)

            let image = UIImage(data: response.data!)
            XCTAssertNotNil(image)

            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testGetUnexistingContent() {

        stub(condition: cdnStubConditions) { _ in
            let data = Data()
            let stubsResponse = OHHTTPStubsResponse(data: data, statusCode: 404, headers: nil)

            return stubsResponse
        }

        let security = Seeds.Securities.basic
        let fileLink = FileLink(handle: "MY-HANDLE", apiKey: "MY-API-KEY", security: security)

        let expectedRequestURL = Config.cdnURL
            .appendingPathComponent(
                "security=policy:\(security.encodedPolicy)," +
                "signature:\(security.signature)"
            )
            .appendingPathComponent("MY-HANDLE")

        let expectation = self.expectation(description: "request should fail with a 404")

        var response: NetworkDataResponse?

        fileLink.getContent { (resp) in

            response = resp
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(response?.response?.statusCode, 404)
        XCTAssertEqual(response?.request?.url, expectedRequestURL)
        XCTAssertNotNil(response?.error)
    }

    func testGetContentWithParameters() {

        stub(condition: cdnStubConditions) { _ in
            let data = Data()

            return OHHTTPStubsResponse(data: data, statusCode: 200, headers: nil)
        }

        let fileLink = FileLink(handle: "MY-HANDLE", apiKey: "MY-API-KEY")
        let expectedRequestURL = Config.cdnURL.appendingPathComponent("MY-HANDLE")

        var expectedURLComponents = URLComponents(url: expectedRequestURL,
                                                  resolvingAgainstBaseURL: true)!

        expectedURLComponents.queryItems = [
            URLQueryItem(name: "foo", value: "123"),
            URLQueryItem(name: "bar", value: "321")
        ]

        let expectation = self.expectation(description: "request should succeed")

        fileLink.getContent(parameters: ["foo": "123", "bar": "321"]) { (response) in

            XCTAssertNotNil(response.request?.url)

            let actualURLComponents = URLComponents(url: response.request!.url!,
                                                    resolvingAgainstBaseURL: true)!

            XCTAssertEqual(actualURLComponents.fragment, expectedURLComponents.fragment)

            for item in actualURLComponents.queryItems! {

                XCTAssertTrue(expectedURLComponents.queryItems!.contains(item))
            }

            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testGetContentWithDownloadProgressMonitoring() {

        stub(condition: cdnStubConditions) { _ in
            let stubPath = OHPathForFile("sample.jpg", type(of: self))!

            let httpHeaders: [AnyHashable: Any] = [
                "Content-Type": "image/jpeg",
                "Content-Length": "200367"
            ]

            return fixture(filePath: stubPath, headers: httpHeaders).requestTime(0.2, responseTime: 2)
        }

        let fileLink = FileLink(handle: "MY-HANDLE", apiKey: "MY-API-KEY")
        let progressExpectation = self.expectation(description: "request should report preogress")

        let downloadProgress: ((Progress) -> Void) = { progress in

            if progress.fractionCompleted == 1.0 {
                progressExpectation.fulfill()
            }
        }

        fileLink.getContent(downloadProgress: downloadProgress) { _ in }
        waitForExpectations(timeout: 3, handler: nil)
    }

}
