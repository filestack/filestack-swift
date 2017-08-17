//
//  Data+Base64MD5Digest.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/28/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import Arcane

extension Data {

    /// Base64-encoded 128-bit MD5 digest (according to RFC 1864)
    internal func base64MD5Digest() -> String {

        return String(data: Base64.MD5(self), encoding: .utf8)!
    }
}
