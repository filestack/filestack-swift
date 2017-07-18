//
//  Config.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 03/07/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


internal struct Config {

    static let apiURL = URL(string: "https://www.filestackapi.com/api")!
    static let cdnURL = URL(string: "https://cdn.filestackcontent.com")!
    static let processURL = URL(string: "https://process.filestackapi.com")!

    static let multipartStartURL = URL(string: "https://upload.filestackapi.com/multipart/start")!
    static let multipartUploadURL = URL(string: "https://upload.filestackapi.com/multipart/upload")!
    static let multipartCompleteURL = URL(string: "https://upload.filestackapi.com/multipart/complete")!

    static let defaultChunkSize = 5 * pow(1024, 2) // 5MB

    static let filePath = "file"
    static let storePath = "store"
    static let metadataPath = "metadata"

    static let validHTTPResponseCodes = Array(200..<300)
}
