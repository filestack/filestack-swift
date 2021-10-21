//
//  UserDefault.swift
//  Doorkeeper
//
//  Created by Ruben Nine on 6/10/21.
//

import Foundation

/// Allows to match for optionals with generics that are defined as non-optional.
protocol AnyOptional {
    /// Returns `true` if `nil`, otherwise `false`.
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    public var isNil: Bool { self == nil }
}

@propertyWrapper
struct UserDefault<Value: Codable> {
    let key: String
    let defaultValue: Value
    var container: UserDefaults = .standard

    var wrappedValue: Value {
        get {
            if let data = container.object(forKey: key) as? Data,
                let user = try? JSONDecoder().decode(Value.self, from: data) {
                return user
            }

            return defaultValue
        }

        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                container.set(encoded, forKey: key)
            }
        }
    }
}
