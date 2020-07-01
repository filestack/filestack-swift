//
//  Uploadable+reader.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 10/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

extension Uploadable {
    var reader: UploadableReader? {
        switch self {
        case let url as URL: return URLReader(url: url)
        case let data as Data: return DataReader(data: data)
        default: return nil
        }
    }
}
