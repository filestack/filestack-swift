//
//  MultipartUploadTests.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 23/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import XCTest
import OHHTTPStubs
@testable import FilestackSDK

class MultipartUploadTests: XCTestCase {
    static private let largeFileSize: Int = 6034668
    static private let sampleFileSize: Int = 200367
    private let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    private let chunkSize = 1 * Int(pow(Double(1024), Double(2)))
    private let partSize = 8 * Int(pow(Double(1024), Double(2)))
    private var currentPart = 1
    private var currentOffset = 0

    override func setUp() {
        currentPart = 1
        currentOffset = 0
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
    }

    func testRegularMultiPartUpload() {
        var hitCount = 0

        stubRegularMultipartRequest(hitCount: &hitCount)

        let expectation = self.expectation(description: "request should succeed")

        var response: NetworkJSONResponse?
        client.multiPartUpload(from: largeFileUrl, useIntelligentIngestionIfAvailable: false) { (resp) in
            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertEqual(hitCount, 1)
        XCTAssertEqual(response?.json?["handle"] as? String, "6GKA0wnQWO7tKaGu2YXA")
        XCTAssertEqual(response?.json?["size"] as? Int, MultipartUploadTests.largeFileSize)
        XCTAssertEqual(response?.json?["filename"] as? String, "large.jpg")
        XCTAssertEqual(response?.json?["status"] as? String, "Stored")
        XCTAssertEqual(response?.json?["url"] as? String, "https://cdn.filestackcontent.com/6GKA0wnQWO7tKaGu2YXA")
        XCTAssertEqual(response?.json?["mimetype"] as? String, "image/jpeg")
    }

    func testResumableMultiPartUpload() {
        stubMultipartStartRequest(supportsIntelligentIngestion: true)
        stubMultipartPostPartRequest()
        stubMultipartPutRequest()
        stubMultipartCommitRequest()
        stubMultipartCompleteRequest()

        let expectation = self.expectation(description: "request should succeed")
        let progressExpectation = self.expectation(description: "request should succeed")

        var json: [String: Any]!

        let progressHandler: ((Progress) -> Void) = { progress in
            if progress.completedUnitCount == MultipartUploadTests.largeFileSize {
                progressExpectation.fulfill()
            }
        }

        client.multiPartUpload(from: largeFileUrl, uploadProgress: progressHandler) { (resp) in
            json = resp.json
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertEqual(json["handle"] as? String, "6GKA0wnQWO7tKaGu2YXA")
        XCTAssertEqual(json["size"] as? Int, MultipartUploadTests.largeFileSize)
        XCTAssertEqual(json["filename"] as? String, "large.jpg")
        XCTAssertEqual(json["status"] as? String, "Stored")
        XCTAssertEqual(json["url"] as? String, "https://cdn.filestackcontent.com/6GKA0wnQWO7tKaGu2YXA")
        XCTAssertEqual(json["mimetype"] as? String, "image/jpeg")
    }

    func testCancellingResumableMultiPartUpload() {
        stubMultipartStartRequest(supportsIntelligentIngestion: true)
        stubMultipartPostPartRequest()
        stubMultipartPutRequest()
        stubMultipartCommitRequest()
        stubMultipartCompleteRequest(requestTime: 5.0, responseTime: 5.0)

        let expectation = self.expectation(description: "request should succeed")

        var error: Error!

        let multipartUpload = client.multiPartUpload(from: sampleFileUrl, uploadProgress: nil) { (resp) in
            error = resp.error
            expectation.fulfill()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            multipartUpload.cancel()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertNotNil(error)
    }

    func testResumableMultiPartUploadWithDownNetworkOnStart() {
        let uploadMultipartStartStubConditions = isScheme(Config.uploadURL.scheme!) &&
            isHost(Config.uploadURL.host!) &&
            isPath("/multipart/start") &&
            isMethodPOST()

        stub(condition: uploadMultipartStartStubConditions) { _ in
            let noConnectionCode = Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue)
            let notConnectedError = NSError(domain: NSURLErrorDomain, code: noConnectionCode, userInfo: nil)
            return OHHTTPStubsResponse(error: notConnectedError)
        }

        let expectation = self.expectation(description: "request should succeed")

        var response: NetworkJSONResponse?

        client.multiPartUpload(from: largeFileUrl, useIntelligentIngestionIfAvailable: true) { (resp) in
            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertNotNil(response?.error)
    }

    func testResumableMultiPartUploadWithDownNetworkOnPut() {
        stubMultipartStartRequest(supportsIntelligentIngestion: true)
        stubMultipartPostPartRequest()

        let uploadMultipartPutStubConditions = isScheme("https") &&
            isHost("s3.amazonaws.com") &&
            isMethodPUT()

        stub(condition: uploadMultipartPutStubConditions) { _ in
            let noConnectionCode = Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue)
            let notConnectedError = NSError(domain: NSURLErrorDomain, code: noConnectionCode, userInfo: nil)
            return OHHTTPStubsResponse(error: notConnectedError)
        }

        let expectation = self.expectation(description: "request should succeed")

        var error: Error?
        client.multiPartUpload(from: sampleFileUrl) { (resp) in
            error = resp.error
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertNotNil(error)
    }

    func testMultiFileUploadWithOneFile() {
        var hitCount = 0
        stubRegularMultipartRequest(hitCount: &hitCount)

        let expectation = self.expectation(description: "request should succeed")

        var responses: [NetworkJSONResponse]!
        client.multiFileUpload(from: [sampleFileUrl], useIntelligentIngestionIfAvailable: false) { (resp) in
            responses = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertEqual(hitCount, 1)
        XCTAssertEqual(responses.count, 1)
        let json = responses.first!.json!
        XCTAssertEqual(json["handle"] as? String, "6GKA0wnQWO7tKaGu2YXA")
        XCTAssertEqual(json["size"] as? Int, MultipartUploadTests.largeFileSize)
        XCTAssertEqual(json["filename"] as? String, "large.jpg")
        XCTAssertEqual(json["status"] as? String, "Stored")
        XCTAssertEqual(json["url"] as? String, "https://cdn.filestackcontent.com/6GKA0wnQWO7tKaGu2YXA")
        XCTAssertEqual(json["mimetype"] as? String, "image/jpeg")

    }

    func testMultiFileUploadWithFewFile() {
        var hitCount = 0
        stubRegularMultipartRequest(hitCount: &hitCount)

        let expectation = self.expectation(description: "request should succeed")

        var responses: [NetworkJSONResponse]!
        client.multiFileUpload(from: [sampleFileUrl, sampleFileUrl], useIntelligentIngestionIfAvailable: false) { (resp) in
            responses = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertEqual(responses.count, 2)
    }

    func testMultiFileUploadWithoutAutostart() {
        var hitCount = 0
        stubRegularMultipartRequest(hitCount: &hitCount)

        let expectation = self.expectation(description: "request should succeed")

        var responses: [NetworkJSONResponse]!
        let mfu = client.multiFileUpload(useIntelligentIngestionIfAvailable: false, startUploadImmediately: false) { (resp) in
            responses = resp
            expectation.fulfill()
        }
        mfu.uploadURLs = [sampleFileUrl, sampleFileUrl]
        mfu.uploadFiles()

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertEqual(responses.count, 2)
    }

    func testMultiFileUploadWithoutURLs() {
        var hitCount = 0
        stubRegularMultipartRequest(hitCount: &hitCount)

        let expectation = self.expectation(description: "request should succeed")

        var responses: [NetworkJSONResponse]!
        let mfu = client.multiFileUpload(useIntelligentIngestionIfAvailable: false, startUploadImmediately: false) { (resp) in
            responses = resp
            expectation.fulfill()
        }
        mfu.uploadURLs = []
        mfu.uploadFiles()

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertEqual(responses.count, 0)
    }
}

private extension MultipartUploadTests {
    func stubRegularMultipartRequest(hitCount: inout Int) {
        stubMultipartStartRequest(supportsIntelligentIngestion: false)
        stubMultipartPostPartRequest(parts: ["PART-1"], hitCount: &hitCount)
        stubMultipartPutRequest(part: "PART-1")
        stubMultipartCompleteRequest()
    }

    func stubMultipartStartRequest(supportsIntelligentIngestion: Bool) {
        let uploadMultipartStartStubConditions = isScheme(Config.uploadURL.scheme!) &&
            isHost(Config.uploadURL.host!) &&
            isPath("/multipart/start") &&
            isMethodPOST()

        stub(condition: uploadMultipartStartStubConditions) { _ in
            let headers = ["Content-Type": "application/json"]
            var json = ["location_url": "upload-eu-west-1.filestackapi.com",
                        "uri": "/SOME-URI-HERE",
                        "upload_id": "SOME-UPLOAD-ID",
                        "region": "us-east-1"]
            if supportsIntelligentIngestion {
                json["upload_type"] = "intelligent_ingestion"
            }

            return OHHTTPStubsResponse(jsonObject: json, statusCode: 200, headers: headers)
        }
    }

    func stubMultipartPutRequest(part: String? = nil) {
        var uploadMultipartPutPartStubConditions = isScheme("https") &&
            isHost("s3.amazonaws.com") &&
            isMethodPUT()

        if let part = part {
            uploadMultipartPutPartStubConditions = uploadMultipartPutPartStubConditions && isPath("/\(part)")
        }

        stub(condition: uploadMultipartPutPartStubConditions) { _ in
            let headers = ["Content-Length": "0",
                           "Date": "Wed, 26 Jul 2017 09:16:37 GMT",
                           "Etag": "c9609eb741008bc1556f341f937a287e",
                           "Server": "AmazonS3",
                           "x-amz-id-2": "LxaKVvjp9jAK+ErminkrN8HV0VMOA/Bjkbf4A0cCaDRC6smJZerZqN9PqzRzGfn9p8vvTb6YIfM=",
                           "x-amz-request-id": "7D827E4E5CFD2E7A"]
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: headers)
        }
    }

    func stubMultipartPostPartRequest() {
        let uploadMultipartPostPartStubConditions = isScheme(Config.uploadURL.scheme!) &&
            isHost(Config.uploadURL.host!) &&
            isPath("/multipart/upload") &&
            isMethodPOST()

        stub(condition: uploadMultipartPostPartStubConditions) { _ in
            self.currentOffset += self.chunkSize
            if self.currentOffset >= self.partSize {
                self.currentOffset = 0
                self.currentPart += 1
            }
            let partName = "PART-\(self.currentPart)/\(self.currentOffset)"
            let headers = ["Content-Type": "application/json"]

            return OHHTTPStubsResponse(jsonObject: self.json(partName: partName), statusCode: 200, headers: headers)
        }
    }

    func stubMultipartPostPartRequest(parts: [String], hitCount: inout Int) {
        let partName = parts[hitCount]
        let uploadMultipartPostPartStubConditions = isScheme(Config.uploadURL.scheme!) &&
            isHost(Config.uploadURL.host!) &&
            isPath("/multipart/upload") &&
            isMethodPOST()

        stub(condition: uploadMultipartPostPartStubConditions) { _ in
            let headers = ["Content-Type": "application/json"]
            return OHHTTPStubsResponse(jsonObject: self.json(partName: partName), statusCode: 200, headers: headers)
        }

        hitCount += 1
    }

    func stubMultipartCompleteRequest(requestTime: TimeInterval = 0, responseTime: TimeInterval = 0) {
        let uploadMultipartCompleteStubConditions = isScheme(Config.uploadURL.scheme!) &&
            isHost(Config.uploadURL.host!) &&
            isPath("/multipart/complete") &&
            isMethodPOST()

        stub(condition: uploadMultipartCompleteStubConditions) { _ in
            let headers = ["Content-Type": "application/json"]
            let json: [String: Any] = ["handle": "6GKA0wnQWO7tKaGu2YXA",
                                       "size": MultipartUploadTests.largeFileSize,
                                       "filename": "large.jpg",
                                       "status": "Stored",
                                       "url": "https://cdn.filestackcontent.com/6GKA0wnQWO7tKaGu2YXA",
                                       "mimetype": "image/jpeg"]
            let response = OHHTTPStubsResponse(jsonObject: json, statusCode: 200, headers: headers)
            response.requestTime = requestTime
            response.responseTime = responseTime
            return response
        }
    }

    func stubMultipartCommitRequest() {
        let uploadMultipartCommitStubConditions = isScheme(Config.uploadURL.scheme!) &&
            isHost(Config.uploadURL.host!) &&
            isPath("/multipart/commit") &&
            isMethodPOST()

        stub(condition: uploadMultipartCommitStubConditions) { _ in
            let headers = ["Content-Type": "text/plain; charset=utf-8"]
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: headers)
        }
    }

    var sampleFileUrl: URL {
        return Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "jpg")!
    }

    var largeFileUrl: URL {
        return Bundle(for: type(of: self)).url(forResource: "large", withExtension: "jpg")!
    }

    var client: Client {
        let security = Seeds.Securities.basic
        return Client(apiKey: "MY-OTHER-API-KEY", security: security, storage: .s3)
    }

    func json(partName: String) -> [String: Any] {
        let authorization = """
    AWS4-HMAC-SHA256 Credential=AKIAIBGGXL3I2XTGV4IQ/20170726/us-east-1/s3/aws4_request, \
    SignedHeaders=content-length;content-md5;host;x-amz-date, \
    Signature=6638349931141536177e23f93b4eade99113ccc27ff96cc414b90dee260841c2
    """
        return ["location_url": "upload-eu-west-1.filestackapi.com",
                "url": "https://s3.amazonaws.com/\(partName)",
            "headers": ["Authorization": authorization,
                        "Content-MD5": "yWCet0EAi8FVbzQfk3oofg==",
                        "x-amz-content-sha256": "UNSIGNED-PAYLOAD",
                        "x-amz-date": "20170726T095615Z"]]
    }
}
