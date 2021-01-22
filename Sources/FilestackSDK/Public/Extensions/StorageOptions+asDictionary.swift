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
    /// :nodoc:
    public func asDictionary() -> [String: Any] {
        var options: [String: Any] = [
            "location": location.description.lowercased(),
        ]

        if let region = region {
            options["region"] = region
        }

        if let container = container {
            options["container"] = container
        }

        if let path = path {
            options["path"] = path
        }

        if let filename = filename {
            options["filename"] = filename
        }

        if let mimeType = mimeType {
            options["mimetype"] = mimeType
        }

        if let access = access?.description {
            options["access"] = access
        }

        if let workflows = workflows {
            options["workflows"] = workflows
        }

        return options
    }
}
