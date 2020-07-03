//
//  UploadDescriptor.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 30/06/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import Foundation

struct UploadDescriptor {
    let config: Config
    let options: UploadOptions
    let reader: UploadableReader
    let filename: String
    let filesize: UInt64
    let mimeType: String
    let uri: String
    let region: String
    let uploadID: String
    let useIntelligentIngestion: Bool
}
