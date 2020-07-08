//
//  String+Hmac.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 08/07/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import Foundation
import CommonCrypto

enum HmacAlgorithm {
    case sha1, md5, sha256, sha384, sha512, sha224

    var algorithm: CCHmacAlgorithm {
        switch self {
        case .sha1: return CCHmacAlgorithm(kCCHmacAlgSHA1)
        case .md5: return CCHmacAlgorithm(kCCHmacAlgMD5)
        case .sha256: return CCHmacAlgorithm(kCCHmacAlgSHA256)
        case .sha384: return CCHmacAlgorithm(kCCHmacAlgSHA384)
        case .sha512: return CCHmacAlgorithm(kCCHmacAlgSHA512)
        case .sha224: return CCHmacAlgorithm(kCCHmacAlgSHA224)
        }
    }

    var digestLength: Int32 {
        switch self {
        case .sha1: return CC_SHA1_DIGEST_LENGTH
        case .md5: return CC_MD5_DIGEST_LENGTH
        case .sha256: return CC_SHA256_DIGEST_LENGTH
        case .sha384: return CC_SHA384_DIGEST_LENGTH
        case .sha512: return CC_SHA512_DIGEST_LENGTH
        case .sha224: return CC_SHA224_DIGEST_LENGTH
        }
    }
}

extension String {
    func hmac(algorithm: HmacAlgorithm, key: String) -> String {
        var digest = [UInt8](repeating: 0, count: Int(algorithm.digestLength))
        CCHmac(algorithm.algorithm, key, key.count, self, self.count, &digest)
        let data = Data(digest)

        return data.map { String(format: "%02hhx", $0) }.joined()
    }
}
