//
//  URL+size.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/18/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation


extension URL {

    internal func size() -> UInt64? {

        let fm = FileManager.default
        let fileSize = (try? fm.attributesOfItem(atPath: relativePath))?[.size] as? UInt64

        return fileSize
    }
}
