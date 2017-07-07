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
    private let apiStubConditions = isScheme(Config.apiURL.scheme!) && isHost(Config.apiURL.host!)
    private let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

    override func tearDown() {

        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testInitializerWithHandleAndApiKey() {

        let client = Client(apiKey: "MY-API-KEY")
        let fileLink = client.fileLink(for: "MY-HANDLE")

        XCTAssertEqual(fileLink.handle, "MY-HANDLE")
        XCTAssertEqual(fileLink.apiKey, "MY-API-KEY")
        XCTAssertEqual(fileLink.security, nil)
    }

    func testInitializerWithHandleApiKeyAndSecurity() {

        let security = Seeds.Securities.basic
        let client = Client(apiKey: "MY-API-KEY", security: security)
        let fileLink = client.fileLink(for: "MY-HANDLE")

        XCTAssertEqual(fileLink.handle, "MY-HANDLE")
        XCTAssertEqual(fileLink.apiKey, "MY-API-KEY")
        XCTAssertEqual(fileLink.security, security)
    }

    func testURL() {

        let client = Client(apiKey: "MY-API-KEY")
        let fileLink = client.fileLink(for: "MY-HANDLE")
        let expectedURL = Config.cdnURL.appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(fileLink.url, expectedURL)
    }

    func testURLWithSecurity() {

        let security = Seeds.Securities.basic
        let client = Client(apiKey: "MY-API-KEY", security: security)
        let fileLink = client.fileLink(for: "MY-HANDLE")

        XCTAssertEqual(fileLink.url.absoluteString,
                       Config.cdnURL.absoluteString +
                       "/MY-HANDLE" +
                       "?policy=\(security.encodedPolicy)&signature=\(security.signature)")
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
        let client = Client(apiKey: "MY-API-KEY", security: security)
        let fileLink = client.fileLink(for: "MY-HANDLE")

        let expectation = self.expectation(description: "request should succeed")
        var response: NetworkDataResponse?

        fileLink.getContent() { (resp) in

            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)

        XCTAssertEqual(response?.response?.statusCode, 200)
        XCTAssertNotNil(response?.response)

        XCTAssertEqual(response?.response?.url?.absoluteString,
                       Config.cdnURL.absoluteString +
                       "/MY-HANDLE" +
                       "?policy=\(security.encodedPolicy)&signature=\(security.signature)")

        XCTAssertNotNil(response?.data)
        XCTAssertEqual(response?.data?.count, 200367)
        XCTAssertNil(response?.error)

        let image = UIImage(data: response!.data!)
        XCTAssertNotNil(image)
    }

    func testGetUnexistingContent() {

        stub(condition: cdnStubConditions) { _ in
            return OHHTTPStubsResponse(data: Data(), statusCode: 404, headers: nil)
        }

        let client = Client(apiKey: "MY-API-KEY")
        let fileLink = client.fileLink(for: "MY-HANDLE")
        let expectedRequestURL = Config.cdnURL.appendingPathComponent("MY-HANDLE")

        let expectation = self.expectation(description: "request should fail with a 404")
        var response: NetworkDataResponse?

        fileLink.getContent { (resp) in

            response = resp
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)

        XCTAssertEqual(response?.response?.statusCode, 404)
        XCTAssertEqual(response?.request?.url, expectedRequestURL)
        XCTAssertNotNil(response?.error)
    }

    func testGetContentWithParameters() {

        stub(condition: cdnStubConditions) { _ in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }

        let client = Client(apiKey: "MY-API-KEY")
        let fileLink = client.fileLink(for: "MY-HANDLE")
        let expectation = self.expectation(description: "request should succeed")
        var response: NetworkDataResponse?

        fileLink.getContent(parameters: ["foo": "123", "bar": "321"]) { (resp) in

            response = resp
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)

        XCTAssertNotNil(response?.request?.url)

        XCTAssertEqual(response?.request?.url?.absoluteString,
                       Config.cdnURL.absoluteString +
                       "/MY-HANDLE" +
                       "?bar=321&foo=123")
    }

    func testGetContentWithParametersAndSecurity() {

        stub(condition: cdnStubConditions) { _ in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }

        let security = Seeds.Securities.basic
        let client = Client(apiKey: "MY-API-KEY", security: security)
        let fileLink = client.fileLink(for: "MY-HANDLE")
        let expectation = self.expectation(description: "request should succeed")
        var response: NetworkDataResponse?

        fileLink.getContent(parameters: ["foo": "123", "bar": "321"]) { (resp) in

            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)

        XCTAssertNotNil(response?.request?.url)

        XCTAssertEqual(response?.request?.url?.absoluteString,
                       Config.cdnURL.absoluteString +
                       "/MY-HANDLE" +
                       "?policy=\(security.encodedPolicy)&signature=\(security.signature)" +
                       "&bar=321&foo=123")
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

        let client = Client(apiKey: "MY-API-KEY")
        let fileLink = client.fileLink(for: "MY-HANDLE")
        let progressExpectation = self.expectation(description: "request should report progress")

        let downloadProgress: ((Progress) -> Void) = { progress in

            if progress.fractionCompleted == 1.0 {
                progressExpectation.fulfill()
            }
        }

        fileLink.getContent(downloadProgress: downloadProgress) { _ in }

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testGetContentUsingDefaultQueue() {

        stub(condition: cdnStubConditions) { _ in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }

        let client = Client(apiKey: "MY-API-KEY")
        let fileLink = client.fileLink(for: "MY-HANDLE")

        let expectation = self.expectation(description: "request should succeed")
        var isMainThread: Bool?

        fileLink.getContent() { _ in

            isMainThread = Thread.isMainThread
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)

        XCTAssertTrue(isMainThread!)
    }

    func testGetContentUsingCustomQueue() {

        stub(condition: cdnStubConditions) { _ in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }

        let client = Client(apiKey: "MY-API-KEY")
        let fileLink = client.fileLink(for: "MY-HANDLE")

        let expectation = self.expectation(description: "request should succeed")
        let customQueue = DispatchQueue(label: "com.filestack.my-custom-queue")
        var isMainThread: Bool?

        fileLink.getContent(queue: customQueue) { _ in

            isMainThread = Thread.isMainThread
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)

        XCTAssertFalse(isMainThread!)
    }

    func testDownloadExistingContent() {

        stub(condition: cdnStubConditions) { _ in
            let stubPath = OHPathForFile("sample.jpg", type(of: self))!

            let httpHeaders: [AnyHashable: Any] = [
                "Content-Type": "image/jpeg",
                "Content-Length": "200367"
            ]

            return fixture(filePath: stubPath, headers: httpHeaders)
        }

        let security = Seeds.Securities.basic
        let client = Client(apiKey: "MY-API-KEY", security: security)
        let fileLink = client.fileLink(for: "MY-HANDLE")
        let expectation = self.expectation(description: "request should succeed")
        let destinationURL = URL(fileURLWithPath: documentsPath, isDirectory: true).appendingPathComponent("sample.jpg")
        var response: NetworkDownloadResponse?

        fileLink.download(destinationURL: destinationURL) { (resp) in

            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)

        XCTAssertEqual(response?.response?.statusCode, 200)
        XCTAssertNotNil(response?.response)

        XCTAssertEqual(response?.response?.url?.absoluteString,
                       Config.cdnURL.absoluteString +
                       "/MY-HANDLE" +
                       "?policy=\(security.encodedPolicy)&signature=\(security.signature)")

        XCTAssertEqual(response?.destinationURL, destinationURL)
        XCTAssertNil(response?.error)

        let image = UIImage(contentsOfFile: destinationURL.path)
        XCTAssertNotNil(image)
    }

    func testDownloadUnexistingContent() {

        stub(condition: cdnStubConditions) { _ in
            return OHHTTPStubsResponse(data: Data(), statusCode: 404, headers: nil)
        }

        let client = Client(apiKey: "MY-API-KEY")
        let fileLink = client.fileLink(for: "MY-HANDLE")
        let expectedRequestURL = Config.cdnURL.appendingPathComponent("MY-HANDLE")

        let expectation = self.expectation(description: "request should fail with a 404")
        let destinationURL = URL(fileURLWithPath: documentsPath, isDirectory: true).appendingPathComponent("sample.jpg")
        var response: NetworkDownloadResponse?

        fileLink.download(destinationURL: destinationURL) { (resp) in

            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)

        XCTAssertEqual(response?.response?.statusCode, 404)
        XCTAssertEqual(response?.request?.url, expectedRequestURL)
        XCTAssertNotNil(response?.error)
    }

    func testDownloadWithParameters() {

        stub(condition: cdnStubConditions) { _ in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }

        let client = Client(apiKey: "MY-API-KEY")
        let fileLink = client.fileLink(for: "MY-HANDLE")
        let expectation = self.expectation(description: "request should succeed")
        let destinationURL = URL(fileURLWithPath: documentsPath, isDirectory: true).appendingPathComponent("sample.jpg")
        var response: NetworkDownloadResponse?

        fileLink.download(destinationURL: destinationURL, parameters: ["foo": "123", "bar": "321"]) { (resp) in

            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)

        XCTAssertNotNil(response?.request?.url)

        XCTAssertEqual(response?.request?.url?.absoluteString,
                       Config.cdnURL.absoluteString +
                       "/MY-HANDLE" +
                       "?bar=321&foo=123")
    }

    func testDownloadWithDownloadProgressMonitoring() {

        stub(condition: cdnStubConditions) { _ in
            let stubPath = OHPathForFile("sample.jpg", type(of: self))!

            let httpHeaders: [AnyHashable: Any] = [
                "Content-Type": "image/jpeg",
                "Content-Length": "200367"
            ]

            return fixture(filePath: stubPath, headers: httpHeaders).requestTime(0.2, responseTime: 2)
        }

        let client = Client(apiKey: "MY-API-KEY")
        let fileLink = client.fileLink(for: "MY-HANDLE")
        let destinationURL = URL(fileURLWithPath: documentsPath, isDirectory: true).appendingPathComponent("sample.jpg")
        let progressExpectation = self.expectation(description: "request should report progress")

        let downloadProgress: ((Progress) -> Void) = { progress in

            if progress.fractionCompleted == 1.0 {
                progressExpectation.fulfill()
            }
        }

        fileLink.download(destinationURL: destinationURL, downloadProgress: downloadProgress) { _ in }

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testDeleteExistingContent() {

        stub(condition: apiStubConditions) { _ in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }

        let client = Client(apiKey: "MY-API-KEY")
        let fileLink = client.fileLink(for: "MY-HANDLE")
        let expectation = self.expectation(description: "request should complete")
        var response: NetworkDataResponse?

        fileLink.delete { (resp) in

            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)

        XCTAssertEqual(response?.response?.statusCode, 200)
        XCTAssertNil(response?.error)

        XCTAssertEqual(response?.request?.url?.absoluteString,
                       Config.apiURL.absoluteString +
                       "/file/MY-HANDLE" +
                       "?key=MY-API-KEY")
    }

    func testDeleteUnexistingContent() {

        stub(condition: apiStubConditions) { _ in
            return OHHTTPStubsResponse(data: Data(), statusCode: 404, headers: nil)
        }

        let client = Client(apiKey: "MY-API-KEY")
        let fileLink = client.fileLink(for: "MY-HANDLE")
        let expectation = self.expectation(description: "request should complete")
        var response: NetworkDataResponse?

        fileLink.delete { (resp) in

            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)

        XCTAssertEqual(response?.response?.statusCode, 404)
        XCTAssertNotNil(response?.error)
    }

    func testOverwriteExistingContentWithFileURL() {

        let requestExpectation = self.expectation(description: "request should complete")
        var request: URLRequest?

        stub(condition: apiStubConditions) { req in

            request = req
            requestExpectation.fulfill()

            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }

        let client = Client(apiKey: "MY-API-KEY")
        let fileLink = client.fileLink(for: "MY-HANDLE")
        let fileURL = Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "jpg")!
        let expectation = self.expectation(description: "request should complete")
        var response: NetworkDataResponse?

        fileLink.overwrite(fileURL: fileURL) { (resp) in

            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)

        XCTAssertEqual(request?.value(forHTTPHeaderField: "Content-Type"), "application/octet-stream")
        XCTAssertEqual(response?.response?.statusCode, 200)
        XCTAssertNil(response?.error)
    }

    func testOverwriteExistingContentWithRemoteURL() {

        let requestExpectation = self.expectation(description: "request should complete")
        var request: URLRequest?

        stub(condition: apiStubConditions) { req in

            request = req
            requestExpectation.fulfill()

            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }

        let client = Client(apiKey: "MY-API-KEY")
        let fileLink = client.fileLink(for: "MY-HANDLE")
        let remoteURL = URL(string: "https://SOME-REMOTE-PLACE")!
        let responseExpectation = expectation(description: "request should complete")
        var response: NetworkDataResponse?

        fileLink.overwrite(remoteURL: remoteURL) { (resp) in

            response = resp
            responseExpectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)

        XCTAssertEqual(request?.value(forHTTPHeaderField: "Content-Type"), "application/x-www-form-urlencoded; charset=utf-8")
        XCTAssertEqual(response?.response?.statusCode, 200)
        XCTAssertNil(response?.error)
    }

    func testOverwriteUnExistingContentWithRemoteURL() {

        stub(condition: apiStubConditions) { req in
            return OHHTTPStubsResponse(data: Data(), statusCode: 404, headers: nil)
        }

        let client = Client(apiKey: "MY-API-KEY")
        let fileLink = client.fileLink(for: "MY-HANDLE")
        let remoteURL = URL(string: "https://SOME-REMOTE-PLACE")!
        let responseExpectation = expectation(description: "request should complete")
        var response: NetworkDataResponse?

        fileLink.overwrite(remoteURL: remoteURL) { (resp) in

            response = resp
            responseExpectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)

        XCTAssertEqual(response?.response?.statusCode, 404)
        XCTAssertNotNil(response?.error)
    }

    func testOverwriteUnexistingContentWithFileURL() {

        stub(condition: apiStubConditions) { _ in
            return OHHTTPStubsResponse(data: Data(), statusCode: 404, headers: nil)
        }

        let client = Client(apiKey: "MY-API-KEY")
        let fileLink = client.fileLink(for: "MY-HANDLE")
        let fileURL = Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "jpg")!
        let expectation = self.expectation(description: "request should complete")
        var response: NetworkDataResponse?

        fileLink.overwrite(fileURL: fileURL) { (resp) in

            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)

        XCTAssertEqual(response?.response?.statusCode, 404)
        XCTAssertNotNil(response?.error)
    }

    // NOTE: OHHTTPStubs can not simulate data uploads, so we can't test this specific case.
    // func testOverwriteExistingContentWithDataAndUploadProgressReporting() {
    //
    // }

    // NOTE: OHHTTPStubs can not simulate data uploads, so we can't test this specific case.
    // func testOverwriteExistingContentWithFileURLAndUploadProgressReporting() {
    //
    // }
}
