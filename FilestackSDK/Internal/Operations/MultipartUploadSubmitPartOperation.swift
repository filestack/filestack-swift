//
//  MultipartUploadSubmitPartOperation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/20/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Alamofire
import Foundation

typealias MultipartUploadSubmitPartOperation = MultipartUploadSubmitPartProtocol & BaseOperation

protocol MultipartUploadSubmitPartProtocol: AnyObject {
    var part: Int { get }
    var responseEtag: String? { get }
    var didFail: Bool { get }
    var progress: Progress { get }
}
