//
//  DataReader.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 10/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

final class DataReader: UploadableReader {
    // MARK: - Internal Properties

    let size: UInt64

    // MARK: - Private Properties

    private let syncQueue = DispatchQueue(label: "com.filestack.FilestackSDK.DataReader.sync-queue")
    private let data: Data
    private var seekOffset: UInt64

    // MARK: - Lifecycle
    
    init(data: Data) {
        self.data = data
        self.seekOffset = 0
        self.size = UInt64(data.count)
    }
}

// MARK: - Internal Functions

extension DataReader {
    func seek(position: UInt64) {
        self.seekOffset = position
    }

    func read(amount: Int) -> Data {
        let start = Int(truncatingIfNeeded: seekOffset)
        let end: Int = min(start.advanced(by: amount), data.count)

        return data.subdata(in: start ..< end)
    }

    func sync<T>(execute work: () throws -> T) rethrows -> T {
        try syncQueue.sync { try work() }
    }
}
