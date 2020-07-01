//
//  StorageOptions+MultipartFormData.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 16/01/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import Alamofire
import Foundation

extension StorageOptions {
    func append(to form: MultipartFormData) {
        form.append(location.description, named: "store_location")
        form.append(region, named: "store_region")
        form.append(container, named: "store_container")
        form.append(path, named: "store_path")
        form.append(access?.description, named: "store_access")

        if let workflows = workflows {
            let joinedWorkflows = "[\((workflows.map { "\"\($0)\"" }).joined(separator: ","))]"
            form.append(joinedWorkflows, named: "workflows")
        }
    }
}
