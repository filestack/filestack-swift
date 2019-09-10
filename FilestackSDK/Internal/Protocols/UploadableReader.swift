//
//  UploadableReader.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 10/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

protocol UploadableReader {
    var size: UInt64 { get }
    func seek(position: UInt64)
    func read(amount: Int) -> Data
}
