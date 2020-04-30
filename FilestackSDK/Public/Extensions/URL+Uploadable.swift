//
//  URL+Uploadable.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 10/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation
import MobileCoreServices

extension URL: Uploadable {
    public var filename: String? {
        return lastPathComponent
    }

    public var size: UInt64? {
        guard let attributtes = try? FileManager.default.attributesOfItem(atPath: relativePath) else { return nil }

        return (attributtes[.size] as? UInt64)
    }

    public var mimeType: String? {
        guard let uti = uniformTypeIdentifier, let mimeTypeRef = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType) else {
            return nil
        }

        let mimeType = mimeTypeRef.takeUnretainedValue()
        mimeTypeRef.release()

        return mimeType as String
    }

    // MARK: - Private Functions

    private var uniformTypeIdentifier: CFString? {
        let ext = pathExtension as CFString
        guard let utiRef = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext, nil) else { return nil }

        let uti = utiRef.takeUnretainedValue()
        utiRef.release()

        return uti
    }
}
