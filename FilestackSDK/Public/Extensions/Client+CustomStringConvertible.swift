//
//  Client+CustomStringConvertible.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 10/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

public extension Client {
    /// Returns a `String` representation of self.
    override var description: String {
        var components: [String] = []

        components.append("(")
        components.append("apiKey: \(apiKey), ")

        if let security = security {
            components.append("security: \(String(describing: security)), ")
        }

        if let storage = storage {
            components.append("storage: \(String(describing: storage))")
        }

        components.append(")")

        return components.joined()
    }
}
