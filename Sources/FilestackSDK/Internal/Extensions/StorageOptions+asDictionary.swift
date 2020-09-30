//
//  StorageOptions+asDictionary.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 16/01/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import Alamofire
import Foundation

extension StorageOptions {
    func asDictionary() -> [String: Any?] {
        var options: [String: Any?] = [
            "location": location.description,
            "region": region,
            "container": container,
            "path": path,
            "access": access?.description
        ]

        if let workflows = workflows {
            options["workflows"] = workflows
        }

        return options
    }
}
