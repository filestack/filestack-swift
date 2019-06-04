//
//  Config.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 03/07/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


/// :nodoc:
public struct Config {

    public static let apiURL = URL(string: "https://www.filestackapi.com/api")!
    public static let cdnURL = URL(string: "https://cdn.filestackcontent.com")!
    public static let processURL = URL(string: "https://process.filestackapi.com")!
    public static let uploadURL = URL(string: "https://upload.filestackapi.com")!

    public static let filePath = "file"
    public static let storePath = "store"
    public static let metadataPath = "metadata"

    public static let validHTTPResponseCodes = Array(200..<300)
}
