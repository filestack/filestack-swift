//
//  DataReader.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 10/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

final class DataReader: UploadableReader {
    let size: UInt64

    private let data: Data
    private var seekOffset: UInt64

    init(data: Data) {
        self.data = data
        self.seekOffset = 0
        self.size = UInt64(data.count)
    }

    func seek(position: UInt64) {
        self.seekOffset = position
    }

    func read(amount: Int) -> Data {
        let start = Int(truncatingIfNeeded: seekOffset)
        let end: Int = min(start.advanced(by: amount), data.count)

        return data.subdata(in: start ..< end)
    }
}
