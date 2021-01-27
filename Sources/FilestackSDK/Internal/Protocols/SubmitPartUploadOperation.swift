//
//  MultipartUploadSubmitPartOperation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/20/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

protocol SubmitPartUploadOperation: BaseOperation<HTTPURLResponse> {
    var number: Int { get }
    var size: Int { get }
    var progress: Progress { get }
}
