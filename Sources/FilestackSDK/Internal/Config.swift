//
//  Config.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 01/07/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import Foundation

class Config {
    let apiKey: String
    let security: Security?
    var currentUploaders: [Uploader] = []

    init(apiKey: String, security: Security? = nil) {
        self.apiKey = apiKey
        self.security = security
    }
}
