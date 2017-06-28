//
//  PolicyTests.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 28/06/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import XCTest
@testable import FilestackSDK


class PolicyTests: XCTestCase {
    
    func testPolicyInstantiationAndJSONEncoding() {

        let policy = Seeds.Policies.basic

        var jsonData: Data!
        XCTAssertNoThrow(jsonData = try! policy.toJSON())

        var decodedJSON: Any!
        XCTAssertNoThrow(decodedJSON = try! JSONSerialization.jsonObject(with: jsonData))

        let json = decodedJSON as! [String: Any]
        XCTAssertNotNil(json, "Unable to decode JSON object as a dictionary of [String: Any] values.")

        XCTAssertEqual(json["expiry"] as! TimeInterval, 12345)
        XCTAssertEqual(json["call"] as! [String], ["read", "write", "stat", "convert"])
        XCTAssertEqual(json["handle"] as! String, "SOME-HANDLE")
        XCTAssertEqual(json["url"] as! String, "https://some-url.tld")
        XCTAssertEqual(json["max_size"] as! UInt, 1024 * 10)
        XCTAssertEqual(json["min_size"] as! UInt, 1024 * 1)
        XCTAssertEqual(json["path"] as! String, "SOME-PATH")
        XCTAssertEqual(json["container"] as! String, "SOME-CONTAINER")
    }
}
