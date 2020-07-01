//
//  MultipartResponse.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 30/06/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import Alamofire
import Foundation

struct MultipartResponse {
    let response: HTTPURLResponse?
    let error: Error?
    let etag: String?
}
