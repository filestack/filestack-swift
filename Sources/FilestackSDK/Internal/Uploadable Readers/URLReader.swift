//
//  URLReader.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 10/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

final class URLReader: UploadableReader {
    // MARK: - Internal Properties

    let size: UInt64

    // MARK: - Private Properties

    private let syncQueue = DispatchQueue(label: "com.filestack.FilestackSDK.URLReader.sync-queue")
    private let fileHandle: FileHandle

    // MARK: - Lifecycle

    init?(url: URL) {
        guard let fileHandle = try? FileHandle(forReadingFrom: url) else { return nil }

        self.fileHandle = fileHandle
        self.size = fileHandle.seekToEndOfFile()

        fileHandle.seek(toFileOffset: 0)
    }

    deinit {
        fileHandle.closeFile()
    }
}

// MARK: - Internal Functions

extension URLReader {
    func seek(position: UInt64) {
        fileHandle.seek(toFileOffset: position)
    }

    func read(amount: Int) -> Data {
        return fileHandle.readData(ofLength: amount)
    }

    func sync<T>(execute work: () throws -> T) rethrows -> T {
        try syncQueue.sync { try work() }
    }
}
