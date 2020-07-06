//
//  UploadTests.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 23/08/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import OHHTTPStubs
import XCTest
@testable import FilestackSDK

class UploadTests: XCTestCase {
    private static let largeFileSize: Int = 6_034_668
    private static let sampleFileSize: Int = 200_367
    private let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    private let chunkSize = 1 * Int(pow(Double(1024), Double(2)))
    private let partSize = 8 * Int(pow(Double(1024), Double(2)))
    private var currentPart = 1
    private var currentOffset = 0
    private var client: Client!

    private let defaultStoreOptions = StorageOptions(location: .s3, access: .private)

    override func setUp() {
        UploadService.useBackgroundSession = false
        currentPart = 1
        currentOffset = 0
        client = Client(apiKey: "MY-OTHER-API-KEY", security: Seeds.Securities.basic)

        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
        client = nil
    }

    func testRegularMultiPartUpload() {
        var hitCount = 0

        stubRegularMultipartRequest(hitCount: &hitCount)

        let expectation = self.expectation(description: "request should succeed")

        var response: JSONResponse?

        let uploadOptions = UploadOptions(preferIntelligentIngestion: false,
                                          startImmediately: true,
                                          storeOptions: defaultStoreOptions)

        let uploader = client.upload(using: largeFileURL, options: uploadOptions) { resp in
            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertEqual(uploader.progress.totalUnitCount, Int64(UploadTests.largeFileSize))
        XCTAssertEqual(uploader.progress.completedUnitCount, Int64(UploadTests.largeFileSize))
        XCTAssertEqual(uploader.progress.fileTotalCount, 1)
        XCTAssertEqual(uploader.progress.fileCompletedCount, 1)

        XCTAssertEqual(hitCount, 1)
        XCTAssertEqual(response?.json?["handle"] as? String, "6GKA0wnQWO7tKaGu2YXA")
        XCTAssertEqual(response?.json?["size"] as? Int, UploadTests.largeFileSize)
        XCTAssertEqual(response?.json?["filename"] as? String, "large.jpg")
        XCTAssertEqual(response?.json?["status"] as? String, "Stored")
        XCTAssertEqual(response?.json?["url"] as? String, "https://cdn.filestackcontent.com/6GKA0wnQWO7tKaGu2YXA")
        XCTAssertEqual(response?.json?["mimetype"] as? String, "image/jpeg")
    }

    func testIntelligentMultiPartUpload() {
        stubMultipartStartRequest(supportsIntelligentIngestion: true)
        stubMultipartPostPartRequest()
        stubMultipartPutRequest()
        stubMultipartCommitRequest()
        stubMultipartCompleteRequest()

        let expectation = self.expectation(description: "request should succeed")
        var json: [String: Any]!

        let uploader = client.upload(using: largeFileURL) { resp in
            json = resp.json
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertEqual(uploader.progress.totalUnitCount, Int64(UploadTests.largeFileSize))
        XCTAssertEqual(uploader.progress.completedUnitCount, Int64(UploadTests.largeFileSize))
        XCTAssertEqual(uploader.progress.fileTotalCount, 1)
        XCTAssertEqual(uploader.progress.fileCompletedCount, 1)

        XCTAssertEqual(json["handle"] as? String, "6GKA0wnQWO7tKaGu2YXA")
        XCTAssertEqual(json["size"] as? Int, UploadTests.largeFileSize)
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

        var error: Swift.Error!

        let uploader = client.upload(using: sampleFileURL) { resp in
            error = resp.error
            expectation.fulfill()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            uploader.cancel()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertEqual(uploader.progress.totalUnitCount, 0)
        XCTAssertEqual(uploader.progress.completedUnitCount, 0)
        XCTAssertEqual(uploader.progress.fileTotalCount, 1)
        XCTAssertEqual(uploader.progress.fileCompletedCount, 1)

        XCTAssertNotNil(error)
    }

    func testResumableMultiPartUploadWithDownNetworkOnStart() {
        let uploadMultipartStartStubConditions =
            isScheme(Constants.uploadURL.scheme!) &&
            isHost(Constants.uploadURL.host!) &&
            isPath("/multipart/start") &&
            isMethodPOST()

        stub(condition: uploadMultipartStartStubConditions) { _ in
            let noConnectionCode = Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue)
            let notConnectedError = NSError(domain: NSURLErrorDomain, code: noConnectionCode, userInfo: nil)
            return OHHTTPStubsResponse(error: notConnectedError)
        }

        let expectation = self.expectation(description: "request should succeed")

        var response: JSONResponse?

        let uploader = client.upload(using: largeFileURL) { resp in
            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertEqual(uploader.progress.totalUnitCount, 0)
        XCTAssertEqual(uploader.progress.completedUnitCount, 0)
        XCTAssertEqual(uploader.progress.fileTotalCount, 1)
        XCTAssertEqual(uploader.progress.fileCompletedCount, 1)

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

        var error: Swift.Error?

        let uploader = client.upload(using: sampleFileURL) { resp in
            error = resp.error
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertEqual(uploader.progress.totalUnitCount, 0)
        XCTAssertEqual(uploader.progress.completedUnitCount, 0)
        XCTAssertEqual(uploader.progress.fileTotalCount, 1)
        XCTAssertEqual(uploader.progress.fileCompletedCount, 1)

        XCTAssertNotNil(error)
    }

    func testMultiPartUploadWithWorkflows() {
        var hitCount = 0
        let workflows = ["workflow-1", "workflow-2", "workflow-3"]
        let storeOptions = StorageOptions(location: .s3, workflows: workflows)

        let uploadOptions = UploadOptions(preferIntelligentIngestion: true,
                                          startImmediately: true,
                                          storeOptions: storeOptions)

        stubRegularMultipartRequest(hitCount: &hitCount, workflows: workflows)

        let expectation = self.expectation(description: "request should succeed")

        var response: JSONResponse?

        let uploader = client.upload(using: largeFileURL, options: uploadOptions) { resp in
            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertEqual(hitCount, 1)
        XCTAssertNotNil(response?.json)

        let json: [String: Any]! = response?.json

        XCTAssertEqual(uploader.progress.totalUnitCount, Int64(UploadTests.largeFileSize))
        XCTAssertEqual(uploader.progress.completedUnitCount, Int64(UploadTests.largeFileSize))
        XCTAssertEqual(uploader.progress.fileTotalCount, 1)
        XCTAssertEqual(uploader.progress.fileCompletedCount, 1)

        XCTAssertEqual(json["handle"] as? String, "6GKA0wnQWO7tKaGu2YXA")
        XCTAssertEqual(json["size"] as? Int, UploadTests.largeFileSize)
        XCTAssertEqual(json["filename"] as? String, "large.jpg")
        XCTAssertEqual(json["status"] as? String, "Stored")
        XCTAssertEqual(json["url"] as? String, "https://cdn.filestackcontent.com/6GKA0wnQWO7tKaGu2YXA")
        XCTAssertEqual(json["mimetype"] as? String, "image/jpeg")

        let returnedWorkflows: [String: Any]! = json["workflows"] as? [String: Any]

        XCTAssertNotNil(returnedWorkflows["workflow-1"])
        XCTAssertNotNil(returnedWorkflows["workflow-2"])
        XCTAssertNotNil(returnedWorkflows["workflow-3"])
    }

    func testMultiFileUploadWithOneFile() {
        var hitCount = 0
        stubRegularMultipartRequest(hitCount: &hitCount)

        let expectation = self.expectation(description: "request should succeed")

        var responses: [JSONResponse]!

        let uploadOptions = UploadOptions(preferIntelligentIngestion: false,
                                          startImmediately: true,
                                          storeOptions: defaultStoreOptions)

        let uploader = client.upload(using: [sampleFileURL], options: uploadOptions) { resp in
            responses = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertEqual(hitCount, 1)
        XCTAssertEqual(responses.count, 1)

        XCTAssertEqual(uploader.progress.totalUnitCount, Int64(UploadTests.sampleFileSize))
        XCTAssertEqual(uploader.progress.completedUnitCount, Int64(UploadTests.sampleFileSize))
        XCTAssertEqual(uploader.progress.fileTotalCount, 1)
        XCTAssertEqual(uploader.progress.fileCompletedCount, 1)

        let json = responses.first!.json!

        XCTAssertEqual(json["handle"] as? String, "6GKA0wnQWO7tKaGu2YXA")
        XCTAssertEqual(json["size"] as? Int, UploadTests.largeFileSize)
        XCTAssertEqual(json["filename"] as? String, "large.jpg")
        XCTAssertEqual(json["status"] as? String, "Stored")
        XCTAssertEqual(json["url"] as? String, "https://cdn.filestackcontent.com/6GKA0wnQWO7tKaGu2YXA")
        XCTAssertEqual(json["mimetype"] as? String, "image/jpeg")
    }

    func testMultiFileUploadWithFewFile() {
        var hitCount = 0
        stubRegularMultipartRequest(hitCount: &hitCount)

        let expectation = self.expectation(description: "request should succeed")

        var responses: [JSONResponse]!

        let uploadOptions = UploadOptions(preferIntelligentIngestion: false,
                                          startImmediately: true,
                                          storeOptions: defaultStoreOptions)

        let uploader = client.upload(using: [sampleFileURL, sampleFileURL], options: uploadOptions) { resp in
            responses = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertEqual(uploader.progress.totalUnitCount, Int64(UploadTests.sampleFileSize * 2))
        XCTAssertEqual(uploader.progress.completedUnitCount, Int64(UploadTests.sampleFileSize * 2))
        XCTAssertEqual(uploader.progress.fileTotalCount, 2)
        XCTAssertEqual(uploader.progress.fileCompletedCount, 2)

        XCTAssertEqual(responses.count, 2)
    }

    func testMultiFileUploadWithoutAutostart() {
        var hitCount = 0
        stubRegularMultipartRequest(hitCount: &hitCount)

        let expectation = self.expectation(description: "request should succeed")

        var responses: [JSONResponse]!

        let uploadOptions = UploadOptions(preferIntelligentIngestion: false,
                                          startImmediately: false,
                                          storeOptions: defaultStoreOptions)

        let uploader = client.upload(options: uploadOptions) { resp in
            responses = resp
            expectation.fulfill()
        }

        uploader.add(uploadables: [sampleFileURL, sampleFileURL])
        uploader.start()

        waitForExpectations(timeout: 15, handler: nil)

        XCTAssertEqual(uploader.progress.totalUnitCount, Int64(UploadTests.sampleFileSize * 2))
        XCTAssertEqual(uploader.progress.completedUnitCount, Int64(UploadTests.sampleFileSize * 2))
        XCTAssertEqual(uploader.progress.fileTotalCount, 2)
        XCTAssertEqual(uploader.progress.fileCompletedCount, 2)

        XCTAssertEqual(responses.count, 2)
    }
}

// MARK: - Private Functions

private extension UploadTests {
    func stubRegularMultipartRequest(hitCount: inout Int, workflows: [String]? = nil) {
        stubMultipartStartRequest(supportsIntelligentIngestion: false)
        stubMultipartPostPartRequest(parts: ["PART-1"], hitCount: &hitCount)
        stubMultipartPutRequest(part: "PART-1")
        stubMultipartCompleteRequest(workflows: workflows)
    }

    func stubMultipartStartRequest(supportsIntelligentIngestion: Bool) {
        let uploadMultipartStartStubConditions =
            isScheme(Constants.uploadURL.scheme!) &&
            isHost(Constants.uploadURL.host!) &&
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
        let uploadMultipartPostPartStubConditions =
            isScheme(Constants.uploadURL.scheme!) &&
            isHost(Constants.uploadURL.host!) &&
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

        let uploadMultipartPostPartStubConditions =
            isScheme(Constants.uploadURL.scheme!) &&
            isHost(Constants.uploadURL.host!) &&
            isPath("/multipart/upload") &&
            isMethodPOST()

        stub(condition: uploadMultipartPostPartStubConditions) { _ in
            let headers = ["Content-Type": "application/json"]
            return OHHTTPStubsResponse(jsonObject: self.json(partName: partName), statusCode: 200, headers: headers)
        }

        hitCount += 1
    }

    func stubMultipartCompleteRequest(requestTime: TimeInterval = 0, responseTime: TimeInterval = 0, workflows: [String]? = nil) {
        let uploadMultipartCompleteStubConditions = isScheme(Constants.uploadURL.scheme!) &&
            isHost(Constants.uploadURL.host!) &&
            isPath("/multipart/complete") &&
            isMethodPOST()

        stub(condition: uploadMultipartCompleteStubConditions) { _ in
            let headers = ["Content-Type": "application/json"]
            var json: [String: Any] = ["handle": "6GKA0wnQWO7tKaGu2YXA",
                                       "size": UploadTests.largeFileSize,
                                       "filename": "large.jpg",
                                       "status": "Stored",
                                       "url": "https://cdn.filestackcontent.com/6GKA0wnQWO7tKaGu2YXA",
                                       "mimetype": "image/jpeg"]

            if let workflows = workflows {
                // Add workflows to JSON response with a fixed jobid.
                var workflowsDic: [String: [String: String]] = [:]
                for workflow in workflows {
                    workflowsDic[workflow] = ["jobid": "some-jobid"]
                }
                json["workflows"] = workflowsDic
            }

            let response = OHHTTPStubsResponse(jsonObject: json, statusCode: 200, headers: headers)
            response.requestTime = requestTime
            response.responseTime = responseTime
            return response
        }
    }

    func stubMultipartCommitRequest() {
        let uploadMultipartCommitStubConditions =
            isScheme(Constants.uploadURL.scheme!) &&
            isHost(Constants.uploadURL.host!) &&
            isPath("/multipart/commit") &&
            isMethodPOST()

        stub(condition: uploadMultipartCommitStubConditions) { _ in
            let headers = ["Content-Type": "text/plain; charset=utf-8"]
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: headers)
        }
    }

    var sampleFileURL: URL {
        return Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "jpg")!
    }

    var largeFileURL: URL {
        return Bundle(for: type(of: self)).url(forResource: "large", withExtension: "jpg")!
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
