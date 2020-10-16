//
//  URL+Deletable.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 16/10/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import Foundation

extension URL: Deletable {
    func delete() {
        guard isDeletable else { return }
        try? FileManager.default.removeItem(at: self)
    }
}

private extension URL {
    var isDeletable: Bool {
        return path.starts(with: FileManager.default.temporaryDirectory.path)
    }
}
