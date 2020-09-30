//
//  Data+Uploadable.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 10/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

extension Data: Uploadable {
    public var filename: String? { nil }
    public var size: UInt64? { UInt64(count) }
    public var mimeType: String? { nil }
}
