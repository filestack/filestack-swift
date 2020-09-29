//
//  FileLinkTests.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 03/07/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import OHHTTPStubs
import OHHTTPStubsSwift
import XCTest
import Alamofire
@testable import FilestackSDK

class FileLinkTests: XCTestCase {
    private let cdnStubConditions = isScheme(Constants.apiURL.scheme!) && isHost(Constants.apiURL.host!)
    private let apiStubConditions = isScheme(Constants.apiURL.scheme!) && isHost(Constants.apiURL.host!)
    private let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

    override func tearDown() {
        super.tearDown()
        HTTPStubs.removeAllStubs()
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
        let expectedURL = Constants.apiURL.appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(fileLink.url, expectedURL)
    }

    func testURLWithSecurity() {
        let security = Seeds.Securities.basic
        let client = Client(apiKey: "MY-API-KEY", security: security)
        let fileLink = client.fileLink(for: "MY-HANDLE")

        XCTAssertEqual(fileLink.url.absoluteString,
                       Constants.apiURL.absoluteString +
                           "/MY-HANDLE" +
                           "?policy=\(security.encodedPolicy)&signature=\(security.signature)")
    }

    func testGetExistingContent() {
        stub(condition: cdnStubConditions) { _ in
            let stubPath = OHPathForFile("sample.jpg", type(of: self))!

            let httpHeaders: [AnyHashable: Any] = [
                "Content-Type": "image/jpeg",
                "Content-Length": "200367",
            ]

            return fixture(filePath: stubPath, headers: httpHeaders)
        }

        let security = Seeds.Securities.basic
        let client = Client(apiKey: "MY-API-KEY", security: security)
        let fileLink = client.fileLink(for: "MY-HANDLE")

        let expectation = self.expectation(description: "request should succeed")
        var response: FilestackSDK.DataResponse?

        fileLink.getContent { resp in

            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertEqual(response?.response?.statusCode, 200)
        XCTAssertNotNil(response?.response)

        XCTAssertEqual(response?.response?.url?.absoluteString,
                       Constants.apiURL.absoluteString +
                           "/MY-HANDLE" +
                           "?policy=\(security.encodedPolicy)&signature=\(security.signature)")

        XCTAssertNotNil(response?.data)
        XCTAssertEqual(response?.data?.count, 200_367)
        XCTAssertNil(response?.error)

        let image = UIImage(data: response!.data!)
        XCTAssertNotNil(image)
    }

    func testGetUnexistingContent() {
        stub(condition: cdnStubConditions) { _ in
            HTTPStubsResponse(data: Data(), statusCode: 404, headers: nil)
        }

        let client = Client(apiKey: "MY-API-KEY")
        let fileLink = client.fileLink(for: "MY-HANDLE")
        let expectedRequestURL = Constants.apiURL.appendingPathComponent("MY-HANDLE")

        let expectation = self.expectation(description: "request should fail with a 404")
        var response: FilestackSDK.DataResponse?

        fileLink.getContent { resp in

            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertEqual(response?.response?.statusCode, 404)
        XCTAssertEqual(response?.request?.url, expectedRequestURL)
        XCTAssertNotNil(response?.error)
    }

    func testGetContentWithParameters() {
        stub(condition: cdnStubConditions) { _ in
            HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }

        let client = Client(apiKey: "MY-API-KEY")
        let fileLink = client.fileLink(for: "MY-HANDLE")
        let expectation = self.expectation(description: "request should succeed")
        var response: FilestackSDK.DataResponse?

        fileLink.getContent(parameters: ["foo": "123", "bar": "321"]) { resp in

            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertNotNil(response?.request?.url)

        XCTAssertEqual(response?.request?.url?.absoluteString,
                       Constants.apiURL.absoluteString +
                           "/MY-HANDLE" +
                           "?bar=321&foo=123")
    }

    func testGetContentWithParametersAndSecurity() {
        stub(condition: cdnStubConditions) { _ in
            HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }

        let security = Seeds.Securities.basic
        let client = Client(apiKey: "MY-API-KEY", security: security)
        let fileLink = client.fileLink(for: "MY-HANDLE")
        let expectation = self.expectation(description: "request should succeed")
        var response: FilestackSDK.DataResponse?

        fileLink.getContent(parameters: ["foo": "123", "bar": "321"]) { resp in

            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertNotNil(response?.request?.url)

        XCTAssertEqual(response?.request?.url?.absoluteString,
                       Constants.apiURL.absoluteString +
                           "/MY-HANDLE" +
                           "?policy=\(security.encodedPolicy)&signature=\(security.signature)" +
                           "&bar=321&foo=123")
    }

    func testGetContentWithDownloadProgressMonitoring() {
        stub(condition: cdnStubConditions) { _ in
            let stubPath = OHPathForFile("sample.jpg", type(of: self))!

            let httpHeaders: [AnyHashable: Any] = [
                "Content-Type": "image/jpeg",
                "Content-Length": "200367",
            ]

            return fixture(filePath: stubPath, headers: httpHeaders).requestTime(0.2, responseTime: 2)
        }

        let client = Client(apiKey: "MY-API-KEY")
        let fileLink = client.fileLink(for: "MY-HANDLE")
        let progressExpectation = expectation(description: "request should report progress")

        let downloadProgress: ((Progress) -> Void) = { progress in

            if progress.fractionCompleted == 1.0 {
                progressExpectation.fulfill()
            }
        }

        fileLink.getContent(downloadProgress: downloadProgress) { _ in }

        waitForExpectations(timeout: 15, handler: nil)
    }

    func testGetContentUsingDefaultQueue() {
        stub(condition: cdnStubConditions) { _ in
            HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }

        let client = Client(apiKey: "MY-API-KEY")
        let fileLink = client.fileLink(for: "MY-HANDLE")

        let expectation = self.expectation(description: "request should succeed")
        var isMainThread: Bool?

        fileLink.getContent { _ in

            isMainThread = Thread.isMainThread
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertTrue(isMainThread!)
    }

    func testGetContentUsingCustomQueue() {
        stub(condition: cdnStubConditions) { _ in
            HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
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

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertFalse(isMainThread!)
    }

    func testDownloadExistingContent() {
        stub(condition: cdnStubConditions) { _ in
            let stubPath = OHPathForFile("sample.jpg", type(of: self))!

            let httpHeaders: [AnyHashable: Any] = [
                "Content-Type": "image/jpeg",
                "Content-Length": "200367",
            ]

            return fixture(filePath: stubPath, headers: httpHeaders)
        }

        let security = Seeds.Securities.basic
        let client = Client(apiKey: "MY-API-KEY", security: security)
        let fileLink = client.fileLink(for: "MY-HANDLE")
        let expectation = self.expectation(description: "request should succeed")
        let destinationURL = URL(fileURLWithPath: documentsPath, isDirectory: true).appendingPathComponent("sample.jpg")
        var response: FilestackSDK.DownloadResponse?

        fileLink.download(destinationURL: destinationURL) { resp in

            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertEqual(response?.response?.statusCode, 200)
        XCTAssertNotNil(response?.response)

        XCTAssertEqual(response?.response?.url?.absoluteString,
                       Constants.apiURL.absoluteString +
                           "/MY-HANDLE" +
                           "?policy=\(security.encodedPolicy)&signature=\(security.signature)")

        XCTAssertEqual(response?.destinationURL, destinationURL)
        XCTAssertNil(response?.error)

        let image = UIImage(contentsOfFile: destinationURL.path)
        XCTAssertNotNil(image)
    }

    func testDownloadUnexistingContent() {
        stub(condition: cdnStubConditions) { _ in
            HTTPStubsResponse(data: Data(), statusCode: 404, headers: nil)
        }

        let client = Client(apiKey: "MY-API-KEY")
        let fileLink = client.fileLink(for: "MY-HANDLE")
        let expectedRequestURL = Constants.apiURL.appendingPathComponent("MY-HANDLE")

        let expectation = self.expectation(description: "request should fail with a 404")
        let destinationURL = URL(fileURLWithPath: documentsPath, isDirectory: true).appendingPathComponent("sample.jpg")
        var response: FilestackSDK.DownloadResponse?

        fileLink.download(destinationURL: destinationURL) { resp in

            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertEqual(response?.response?.statusCode, 404)
        XCTAssertEqual(response?.request?.url, expectedRequestURL)
        XCTAssertNotNil(response?.error)
    }

    func testDownloadWithParameters() {
        stub(condition: cdnStubConditions) { _ in
            HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }

        let client = Client(apiKey: "MY-API-KEY")
        let fileLink = client.fileLink(for: "MY-HANDLE")
        let expectation = self.expectation(description: "request should succeed")
        let destinationURL = URL(fileURLWithPath: documentsPath, isDirectory: true).appendingPathComponent("sample.jpg")
        var response: FilestackSDK.DownloadResponse?

        fileLink.download(destinationURL: destinationURL, parameters: ["foo": "123", "bar": "321"]) { resp in

            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertNotNil(response?.request?.url)

        XCTAssertEqual(response?.request?.url?.absoluteString,
                       Constants.apiURL.absoluteString +
                           "/MY-HANDLE" +
                           "?bar=321&foo=123")
    }

    func testDownloadWithDownloadProgressMonitoring() {
        stub(condition: cdnStubConditions) { _ in
            let stubPath = OHPathForFile("sample.jpg", type(of: self))!

            let httpHeaders: [AnyHashable: Any] = [
                "Content-Type": "image/jpeg",
                "Content-Length": "200367",
            ]

            return fixture(filePath: stubPath, headers: httpHeaders).requestTime(0.2, responseTime: 2)
        }

        let client = Client(apiKey: "MY-API-KEY")
        let fileLink = client.fileLink(for: "MY-HANDLE")
        let destinationURL = URL(fileURLWithPath: documentsPath, isDirectory: true).appendingPathComponent("sample.jpg")
        let progressExpectation = expectation(description: "request should report progress")

        let downloadProgress: ((Progress) -> Void) = { progress in

            if progress.fractionCompleted == 1.0 {
                progressExpectation.fulfill()
            }
        }

        fileLink.download(destinationURL: destinationURL, downloadProgress: downloadProgress) { _ in }

        waitForExpectations(timeout: 15, handler: nil)
    }

    func testDeleteExistingContent() {
        stub(condition: apiStubConditions) { _ in
            HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }

        let client = Client(apiKey: "MY-API-KEY")
        let fileLink = client.fileLink(for: "MY-HANDLE")
        let expectation = self.expectation(description: "request should complete")
        var response: FilestackSDK.DataResponse?

        fileLink.delete { resp in

            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertEqual(response?.response?.statusCode, 200)
        XCTAssertNil(response?.error)

        XCTAssertEqual(response?.request?.url?.absoluteString,
                       Constants.apiURL.absoluteString +
                           "/file/MY-HANDLE" +
                           "?key=MY-API-KEY")
    }

    func testDeleteUnexistingContent() {
        stub(condition: apiStubConditions) { _ in
            HTTPStubsResponse(data: Data(), statusCode: 404, headers: nil)
        }

        let client = Client(apiKey: "MY-API-KEY")
        let fileLink = client.fileLink(for: "MY-HANDLE")
        let expectation = self.expectation(description: "request should complete")
        var response: FilestackSDK.DataResponse?

        fileLink.delete { resp in

            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertEqual(response?.response?.statusCode, 404)
        XCTAssertNotNil(response?.error)
    }

    func testOverwriteExistingContentWithFileURL() {
        let requestExpectation = self.expectation(description: "request should complete")
        var request: URLRequest?

        stub(condition: apiStubConditions) { req in

            request = req
            requestExpectation.fulfill()

            return HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }

        let client = Client(apiKey: "MY-API-KEY")
        let fileLink = client.fileLink(for: "MY-HANDLE")
        let fileURL = Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "jpg")!
        let expectation = self.expectation(description: "request should complete")
        var response: FilestackSDK.DataResponse?

        fileLink.overwrite(fileURL: fileURL) { resp in

            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertEqual(request?.value(forHTTPHeaderField: "Content-Type"), "application/octet-stream")
        XCTAssertEqual(response?.response?.statusCode, 200)
        XCTAssertNil(response?.error)
    }

    func testOverwriteExistingContentWithRemoteURL() {
        let requestExpectation = expectation(description: "request should complete")
        var request: URLRequest?

        stub(condition: apiStubConditions) { req in

            request = req
            requestExpectation.fulfill()

            return HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }

        let client = Client(apiKey: "MY-API-KEY")
        let fileLink = client.fileLink(for: "MY-HANDLE")
        let remoteURL = URL(string: "https://SOME-REMOTE-PLACE")!
        let responseExpectation = expectation(description: "request should complete")
        var response: FilestackSDK.DataResponse?

        fileLink.overwrite(remoteURL: remoteURL) { resp in

            response = resp
            responseExpectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertEqual(request?.value(forHTTPHeaderField: "Content-Type"), "application/x-www-form-urlencoded; charset=utf-8")
        XCTAssertEqual(response?.response?.statusCode, 200)
        XCTAssertNil(response?.error)
    }

    func testOverwriteUnExistingContentWithRemoteURL() {
        stub(condition: apiStubConditions) { _ in
            HTTPStubsResponse(data: Data(), statusCode: 404, headers: nil)
        }

        let client = Client(apiKey: "MY-API-KEY")
        let fileLink = client.fileLink(for: "MY-HANDLE")
        let remoteURL = URL(string: "https://SOME-REMOTE-PLACE")!
        let responseExpectation = expectation(description: "request should complete")
        var response: FilestackSDK.DataResponse?

        fileLink.overwrite(remoteURL: remoteURL) { resp in

            response = resp
            responseExpectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertEqual(response?.response?.statusCode, 404)
        XCTAssertNotNil(response?.error)
    }

    func testOverwriteUnexistingContentWithFileURL() {
        stub(condition: apiStubConditions) { _ in
            HTTPStubsResponse(data: Data(), statusCode: 404, headers: nil)
        }

        let client = Client(apiKey: "MY-API-KEY")
        let fileLink = client.fileLink(for: "MY-HANDLE")
        let fileURL = Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "jpg")!
        let expectation = self.expectation(description: "request should complete")
        var response: FilestackSDK.DataResponse?

        fileLink.overwrite(fileURL: fileURL) { resp in

            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertEqual(response?.response?.statusCode, 404)
        XCTAssertNotNil(response?.error)
    }

    func testGetImageTaggingResponse() {
        stub(condition: cdnStubConditions) { _ in
            let headers = ["Content-Type": "application/json"]

            let json = [
                "auto": [
                    "perching bird": 58,
                    "eurasian golden oriole": 57,
                ],
                "user": nil,
            ]

            return HTTPStubsResponse(jsonObject: json, statusCode: 200, headers: headers)
        }

        let security = Seeds.Securities.basic
        let client = Client(apiKey: "MY-API-KEY", security: security)
        let fileLink = client.fileLink(for: "MY-HANDLE")

        let expectation = self.expectation(description: "request should complete")
        var response: JSONResponse?

        fileLink.getTags { resp in

            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        let expectedURL = Constants.apiURL
            .appendingPathComponent("tags")
            .appendingPathComponent("security=policy:\(security.encodedPolicy),signature:\(security.signature)")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(response?.response?.url, expectedURL)
        XCTAssertEqual(response?.response?.statusCode, 200)
        XCTAssertNotNil(response?.json)
        XCTAssertNil(response?.error)
    }

    func testGetSafeForWorkResponse() {
        stub(condition: cdnStubConditions) { _ in
            let headers = ["Content-Type": "application/json"]
            return HTTPStubsResponse(jsonObject: ["sfw": true], statusCode: 200, headers: headers)
        }

        let security = Seeds.Securities.basic
        let client = Client(apiKey: "MY-API-KEY", security: security)
        let fileLink = client.fileLink(for: "MY-HANDLE")

        let expectation = self.expectation(description: "request should complete")
        var response: JSONResponse?

        fileLink.getSafeForWork { resp in

            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        let expectedURL = Constants.apiURL
            .appendingPathComponent("sfw")
            .appendingPathComponent("security=policy:\(security.encodedPolicy),signature:\(security.signature)")
            .appendingPathComponent("MY-HANDLE")

        XCTAssertEqual(response?.response?.url, expectedURL)
        XCTAssertEqual(response?.response?.statusCode, 200)
        XCTAssertEqual(response?.json?["sfw"] as? Bool, true)
        XCTAssertNil(response?.error)
    }

    func testGetMetadata() {
        stub(condition: apiStubConditions) { _ in
            let headers = ["Content-Type": "application/json"]

            let returnedJSON: [String: Any] = [
                "width": 320,
                "height": 280,
                "md5": "de2af2ee5450732a4768442199d6718d",
            ]

            return HTTPStubsResponse(jsonObject: returnedJSON, statusCode: 200, headers: headers)
        }

        let security = Seeds.Securities.basic
        let client = Client(apiKey: "MY-API-KEY", security: security)
        let fileLink = client.fileLink(for: "MY-HANDLE")

        let expectation = self.expectation(description: "request should complete")
        var response: JSONResponse?

        fileLink.getMetadata(options: [.width, .height, .MD5]) { resp in

            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        let expectedBaseURL = Constants.apiURL
            .appendingPathComponent("file")
            .appendingPathComponent("MY-HANDLE")
            .appendingPathComponent("metadata")

        var expectedURLComponents = URLComponents(url: expectedBaseURL, resolvingAgainstBaseURL: false)!

        expectedURLComponents.queryItems = [
            URLQueryItem(name: "width", value: "true"),
            URLQueryItem(name: "height", value: "true"),
            URLQueryItem(name: "md5", value: "true"),
            URLQueryItem(name: "policy", value: security.encodedPolicy),
            URLQueryItem(name: "signature", value: security.signature),
        ]

        let expectedURL = try! expectedURLComponents.asURL()

        XCTAssertEqual(response?.response?.url, expectedURL)
        XCTAssertEqual(response?.response?.statusCode, 200)
        XCTAssertEqual(response?.json?["width"] as? Int, 320)
        XCTAssertEqual(response?.json?["height"] as? Int, 280)
        XCTAssertEqual(response?.json?["md5"] as? String, "de2af2ee5450732a4768442199d6718d")

        XCTAssertNil(response?.error)
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
