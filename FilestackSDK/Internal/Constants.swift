//
//  Constants.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 03/07/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

struct Constants {
    static let apiURL = URL(string: "https://www.filestackapi.com/api")!
    static let uploadURL = URL(string: "https://upload.filestackapi.com")!

    static let filePath = "file"
    static let storePath = "store"
    static let metadataPath = "metadata"

    static let validHTTPResponseCodes = Array(200 ..< 300)
}
