//
//  Data+base64MD5Digest.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/28/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import CommonCrypto
import Foundation

extension Data {
    /// Base64-encoded 128-bit MD5 digest (according to RFC 1864)
    func base64MD5Digest() -> String {
        return Data((withUnsafeBytes { byte -> [UInt8] in
            var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))

            CC_SHA256(byte.baseAddress, CC_LONG(count), &digest)

            return digest
        })).base64EncodedString()
    }
}
