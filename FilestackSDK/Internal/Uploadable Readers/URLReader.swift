//
//  URLReader.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 10/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

final class URLReader: UploadableReader {
    let size: UInt64

    private let fileHandle: FileHandle

    init?(url: URL) {
        guard let fileHandle = try? FileHandle(forReadingFrom: url) else { return nil }

        self.fileHandle = fileHandle
        self.size = fileHandle.seekToEndOfFile()

        fileHandle.seek(toFileOffset: 0)
    }

    deinit {
        fileHandle.closeFile()
    }

    func seek(position: UInt64) {
        fileHandle.seek(toFileOffset: position)
    }

    func read(amount: Int) -> Data {
        return fileHandle.readData(ofLength: amount)
    }
}
