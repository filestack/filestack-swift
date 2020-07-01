//
//  MultipartformData+append.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 30/06/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import Alamofire
import Foundation

extension MultipartFormData {
    func append(_ string: String?, named name: String) {
        guard let data = string?.data(using: .utf8) else { return }
        append(data, withName: name)
    }
}
