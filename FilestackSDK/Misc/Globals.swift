//
//  Globals.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 03/07/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

let cdnService = CDNService()
let apiService = APIService()
let processService = ProcessService()
let uploadService = UploadService()

func attachedDescription(object: CustomStringConvertible, indent: Int = 1, spaces: Int = 4) -> String {
    var components: [String] = []
    for (idx, line) in object.description.components(separatedBy: "\n").enumerated() {
        if idx == 0 {
            components.append(String(line))
        } else {
            components.append("\(String(repeatElement(" ", count: indent * spaces)))\(line)")
        }
    }
    return components.joined(separator: "\n")
}
