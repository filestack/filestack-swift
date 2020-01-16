//
//  StorageOptions+MultipartFormData.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 16/01/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import Foundation
import Alamofire

extension StorageOptions {

    internal func append(to form: MultipartFormData) {
        form.append(location.description, withName: "store_location")
        form.append(region, withName: "store_region")
        form.append(container, withName: "store_container")
        form.append(path, withName: "store_path")
        form.append(access?.description, withName: "store_access")

        if let workflows = workflows {
            let joinedWorkflows = "[\((workflows.map { "\"\($0)\"" }).joined(separator: ","))]"
            form.append(joinedWorkflows, withName: "workflows")
        }
    }
}
