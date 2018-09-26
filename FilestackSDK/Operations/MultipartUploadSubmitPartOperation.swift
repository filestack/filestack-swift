//
//  MultipartUploadSubmitPartOperation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/20/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import Alamofire

typealias MultipartUploadSubmitPartOperation = MultipartUploadSubmitPartProtocol & BaseOperation

protocol MultipartUploadSubmitPartProtocol: class {
  var part: Int {get}
  var responseEtag: String? {get}
  var didFail: Bool {get}
}
