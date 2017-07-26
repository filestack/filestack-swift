//
//  ClientTests.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 28/06/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import XCTest
import OHHTTPStubs
@testable import FilestackSDK


class ClientTests: XCTestCase {

    private let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

    override func tearDown() {

        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testInitializerWithApiKey() {

        let client = Client(apiKey: "MY-API-KEY")

        XCTAssertEqual(client.apiKey, "MY-API-KEY")
        XCTAssertEqual(client.security, nil)
        XCTAssertEqual(client.storage, nil)
    }

    func testInitializerWithApiKeyAndSecurity() {

        let security = Seeds.Securities.basic
        let client = Client(apiKey: "MY-OTHER-API-KEY", security: security)

        XCTAssertEqual(client.apiKey, "MY-OTHER-API-KEY")
        XCTAssertEqual(client.security, security)
        XCTAssertEqual(client.storage, nil)
    }

    func testInitializerWithApiKeySecurityAndStorage() {

        let security = Seeds.Securities.basic
        let client = Client(apiKey: "MY-OTHER-API-KEY", security: security, storage: .s3)

        XCTAssertEqual(client.apiKey, "MY-OTHER-API-KEY")
        XCTAssertEqual(client.security, security)
        XCTAssertEqual(client.storage, .s3)
    }

    func testMultiPartUpload() {

        var currentPostPart = 0

        let uploadMultipartStartStubConditions = isScheme(Config.uploadURL.scheme!) &&
                                                 isHost(Config.uploadURL.host!) &&
                                                 isPath("/multipart/start")

        stub(condition: uploadMultipartStartStubConditions) { _ in

            let headers = ["Content-Type": "application/json"]

            let json = [
                "location_url": "upload-eu-west-1.filestackapi.com",
                "uri": "/SOME-URI-HERE",
                "upload_id": "SOME-UPLOAD-ID",
                "region": "us-east-1"
            ]

            return OHHTTPStubsResponse(jsonObject: json, statusCode: 200, headers: headers)
        }

        let uploadMultipartPostPartStubConditions = isScheme(Config.uploadURL.scheme!) &&
                                                    isHost(Config.uploadURL.host!) &&
                                                    isPath("/multipart/upload")

        stub(condition: uploadMultipartPostPartStubConditions) { _ in

            currentPostPart += 1
            var json: [String: Any] = [:]

            switch currentPostPart {

            case 1:

                json = [
                    "location_url": "upload-eu-west-1.filestackapi.com",
                    "url": "https://s3.amazonaws.com/PART-1",
                    "headers": [
                        "Authorization":
                            "AWS4-HMAC-SHA256 Credential=AKIAIBGGXL3I2XTGV4IQ/20170726/us-east-1/s3/aws4_request, " +
                            "SignedHeaders=content-length;content-md5;host;x-amz-date, " +
                            "Signature=6638349931141536177e23f93b4eade99113ccc27ff96cc414b90dee260841c2",
                        "Content-MD5": "yWCet0EAi8FVbzQfk3oofg==",
                        "x-amz-content-sha256": "UNSIGNED-PAYLOAD",
                        "x-amz-date": "20170726T095615Z"
                    ]
                ]

            case 2:

                json = [
                    "location_url": "upload-eu-west-1.filestackapi.com",
                    "url": "https://s3.amazonaws.com/PART-2",
                    "headers": [
                        "Authorization":
                            "AWS4-HMAC-SHA256 Credential=AKIAIBGGXL3I2XTGV4IQ/20170726/us-east-1/s3/aws4_request, " +
                            "SignedHeaders=content-length;content-md5;host;x-amz-date, " +
                            "Signature=ff708e0ea0dbb7d185297c565c35e38d5800fb3027c192876220516727976802",
                        "Content-MD5": "RskhVO8nyDtZ7K+40l0e+A==",
                        "x-amz-content-sha256": "UNSIGNED-PAYLOAD",
                        "x-amz-date": "20170726T095615Z"
                    ]
                ]

            default:

                XCTAssertTrue(false)
            }

            let headers = ["Content-Type": "application/json"]

            return OHHTTPStubsResponse(jsonObject: json, statusCode: 200, headers: headers)
        }

        let uploadMultipartPutPart1StubConditions = isScheme("https") &&
                                                    isHost("s3.amazonaws.com") &&
                                                    isPath("/PART-1")

        stub(condition: uploadMultipartPutPart1StubConditions) { _ in

            let headers = [
                "Content-Length": "0",
                "Date": "Wed, 26 Jul 2017 09:16:37 GMT",
                "Etag": "c9609eb741008bc1556f341f937a287e",
                "Server": "AmazonS3",
                "x-amz-id-2": "LxaKVvjp9jAK+ErminkrN8HV0VMOA/Bjkbf4A0cCaDRC6smJZerZqN9PqzRzGfn9p8vvTb6YIfM=",
                "x-amz-request-id": "7D827E4E5CFD2E7A"
            ]

            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: headers)
        }

        let uploadMultipartPutPart2StubConditions = isScheme("https") &&
                                                    isHost("s3.amazonaws.com") &&
                                                    isPath("/PART-2")

        stub(condition: uploadMultipartPutPart2StubConditions) { _ in

            let headers = [
                "Content-Length": "0",
                "Date": "Wed, 26 Jul 2017 09:16:32 GMT",
                "Etag": "46c92154ef27c83b59ecafb8d25d1ef8",
                "Server": "AmazonS3",
                "x-amz-id-2": "ed/87OjX7rzM/h7K8VUTIZeErxj4HH3JzywkJZmM9Jb8Uqui6mg7jUJUylA002ACXalAXONG88o=",
                "x-amz-request-id": "80168D89CE7D40E2"
            ]

            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: headers)
        }

        let uploadMultipartCompleteStubConditions = isScheme(Config.uploadURL.scheme!) &&
                                                    isHost(Config.uploadURL.host!) &&
                                                    isPath("/multipart/complete")

        stub(condition: uploadMultipartCompleteStubConditions) { _ in
            let headers = ["Content-Type": "application/json"]

            let json: [String: Any] = [
                "handle": "6GKA0wnQWO7tKaGu2YXA",
                "size": 6034668,
                "filename": "large.jpg",
                "status": "Stored",
                "url": "https://cdn.filestackcontent.com/6GKA0wnQWO7tKaGu2YXA",
                "mimetype": "image/jpeg"
            ]

            return OHHTTPStubsResponse(jsonObject: json, statusCode: 200, headers: headers)
        }

        let security = Seeds.Securities.basic
        let client = Client(apiKey: "MY-OTHER-API-KEY", security: security, storage: .s3)
        let localURL = Bundle(for: type(of: self)).url(forResource: "large", withExtension: "jpg")!
        let expectation = self.expectation(description: "request should succeed")

        var response: NetworkJSONResponse?

        client.multiPartUpload(from: localURL) { (resp) in

            response = resp
            expectation.fulfill()
        }

        waitForExpectations(timeout: 30, handler: nil)

        XCTAssertEqual(response?.json?["handle"] as? String, "6GKA0wnQWO7tKaGu2YXA")
        XCTAssertEqual(response?.json?["size"] as? Int, 6034668)
        XCTAssertEqual(response?.json?["filename"] as? String, "large.jpg")
        XCTAssertEqual(response?.json?["status"] as? String, "Stored")
        XCTAssertEqual(response?.json?["url"] as? String, "https://cdn.filestackcontent.com/6GKA0wnQWO7tKaGu2YXA")
        XCTAssertEqual(response?.json?["mimetype"] as? String, "image/jpeg")
    }
}
