//
//  Data+Base64MD5Digest.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/28/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import CommonCrypto


extension Data {

    /// Base64-encoded 128-bit MD5 digest (according to RFC 1864)
    internal func base64MD5Digest() -> String {

        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))

        let _ = withUnsafeBytes { bytes in
            CC_MD5(bytes, CC_LONG(count), &digest)
        }

        let digestData: Data = Data(bytes: digest)
        let base64Digest = digestData.base64EncodedString()

        return base64Digest
    }
}
