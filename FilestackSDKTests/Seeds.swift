//
//  Seeds.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 28/06/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
@testable import FilestackSDK

struct Seeds {

    struct Policies {

        static let basic = Policy(
            expiry: Date(timeIntervalSince1970: 12345),
            call: [.read, .write, .stat, .convert],
            handle: "SOME-HANDLE",
            url: URL(string: "https://some-url.tld")!,
            maxSize: 1024 * 10,
            minSize: 1024 * 1,
            path: "SOME-PATH",
            container: "SOME-CONTAINER"
        )
    }

    struct Securities {

        static let basic = try! Security(
            policy: Seeds.Policies.basic,
            appSecret: "APP-SECRET"
        )
    }
}
