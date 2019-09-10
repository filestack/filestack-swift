//
//  Tools.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 10/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

struct Tools {
    /// Describes a subject, optionally including children in `only` array and excluding children in `except` array.
    static func describe(subject: Any, only: [String]? = nil, except: [String]? = nil) -> String {
        let mirror = Mirror(reflecting: subject)

        let components: [String] = mirror.children.compactMap {
            guard let label = $0.label else { return nil }

            // Only add children included in `only` array.
            if let only = only, !only.contains(label) {
                return nil
            }

            // Exclude children from `except` array.
            if let except = except, except.contains(label) {
                return nil
            }

            return "\(label): \($0.value)"
        }

        return "\(mirror.subjectType)(\(components.joined(separator: ", ")))"
    }
}
