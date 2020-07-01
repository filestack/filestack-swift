//
//  MinifyJSTransform.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 13/08/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

/// Minifies your JavaScript files.
@objc(FSMinifyJSTransform)
public class MinifyJSTransform: Transform {
    // MARK: - Lifecycle

    /// Initializes a `MinifyJSTransform` object.
    @objc public init() {
        super.init(name: "minify_js")
    }
}

// MARK: - Public Functions

public extension MinifyJSTransform {
    /// Adds the `booleans` option.
    ///
    /// - Parameter value: Whether to enable `booleans` option or not.
    @discardableResult
    @objc func booleans(_ value: Bool) -> Self {
        return appending(key: "booleans", value: value)
    }

    /// Adds the `builtIns` option.
    ///
    /// - Parameter value: Whether to enable `builtIns` option or not.
    @discardableResult
    @objc func builtIns(_ value: Bool) -> Self {
        return appending(key: "builtIns", value: value)
    }

    /// Adds the `consecutiveAdds` option.
    ///
    /// - Parameter value: Whether to enable `consecutiveAdds` option or not.
    @discardableResult
    @objc func consecutiveAdds(_ value: Bool) -> Self {
        return appending(key: "consecutiveAdds", value: value)
    }

    /// Adds the `deadcode` option.
    ///
    /// - Parameter value: Whether to enable `deadcode` option or not.
    @discardableResult
    @objc func deadcode(_ value: Bool) -> Self {
        return appending(key: "deadcode", value: value)
    }

    /// Adds the `evaluate` option.
    ///
    /// - Parameter value: Whether to enable `evaluate` option or not.
    @discardableResult
    @objc func evaluate(_ value: Bool) -> Self {
        return appending(key: "evaluate", value: value)
    }

    /// Adds the `flipComparisons` option.
    ///
    /// - Parameter value: Whether to enable `flipComparisons` option or not.
    @discardableResult
    @objc func flipComparisons(_ value: Bool) -> Self {
        return appending(key: "flipComparisons", value: value)
    }

    /// Adds the `guards` option.
    ///
    /// - Parameter value: Whether to enable `guards` option or not.
    @discardableResult
    @objc func guards(_ value: Bool) -> Self {
        return appending(key: "guards", value: value)
    }

    /// Adds the `infinity` option.
    ///
    /// - Parameter value: Whether to enable `infinity` option or not.
    @discardableResult
    @objc func infinity(_ value: Bool) -> Self {
        return appending(key: "infinity", value: value)
    }

    /// Adds the `mangle` option.
    ///
    /// - Parameter value: Whether to enable `mangle` option or not.
    @discardableResult
    @objc func mangle(_ value: Bool) -> Self {
        return appending(key: "mangle", value: value)
    }

    /// Adds the `memberExpressions` option.
    ///
    /// - Parameter value: Whether to enable `memberExpressions` option or not.
    @discardableResult
    @objc func memberExpressions(_ value: Bool) -> Self {
        return appending(key: "memberExpressions", value: value)
    }

    /// Adds the `mergeVars` option.
    ///
    /// - Parameter value: Whether to enable `mergeVars` option or not.
    @discardableResult
    @objc func mergeVars(_ value: Bool) -> Self {
        return appending(key: "mergeVars", value: value)
    }

    /// Adds the `numericLiterals` option.
    ///
    /// - Parameter value: Whether to enable `numericLiterals` option or not.
    @discardableResult
    @objc func numericLiterals(_ value: Bool) -> Self {
        return appending(key: "numericLiterals", value: value)
    }

    /// Adds the `propertyLiterals` option.
    ///
    /// - Parameter value: Whether to enable `propertyLiterals` option or not.
    @discardableResult
    @objc func propertyLiterals(_ value: Bool) -> Self {
        return appending(key: "propertyLiterals", value: value)
    }

    /// Adds the `regexpConstructors` option.
    ///
    /// - Parameter value: Whether to enable `regexpConstructors` option or not.
    @discardableResult
    @objc func regexpConstructors(_ value: Bool) -> Self {
        return appending(key: "regexpConstructors", value: value)
    }

    /// Adds the `removeConsole` option.
    ///
    /// - Parameter value: Whether to enable `removeConsole` option or not.
    @discardableResult
    @objc func removeConsole(_ value: Bool) -> Self {
        return appending(key: "removeConsole", value: value)
    }

    /// Adds the `removeDebugger` option.
    ///
    /// - Parameter value: Whether to enable `removeDebugger` option or not.
    @discardableResult
    @objc func removeDebugger(_ value: Bool) -> Self {
        return appending(key: "removeDebugger", value: value)
    }

    /// Adds the `removeUndefined` option.
    ///
    /// - Parameter value: Whether to enable `removeUndefined` option or not.
    @discardableResult
    @objc func removeUndefined(_ value: Bool) -> Self {
        return appending(key: "removeUndefined", value: value)
    }

    /// Adds the `simplify` option.
    ///
    /// - Parameter value: Whether to enable `simplify` option or not.
    @discardableResult
    @objc func simplify(_ value: Bool) -> Self {
        return appending(key: "simplify", value: value)
    }

    /// Adds the `simplifyComparisons` option.
    ///
    /// - Parameter value: Whether to enable `simplifyComparisons` option or not.
    @discardableResult
    @objc func simplifyComparisons(_ value: Bool) -> Self {
        return appending(key: "simplifyComparisons", value: value)
    }

    /// Adds the `typeConstructors` option.
    ///
    /// - Parameter value: Whether to enable `typeConstructors` option or not.
    @discardableResult
    @objc func typeConstructors(_ value: Bool) -> Self {
        return appending(key: "typeConstructors", value: value)
    }

    /// Adds the `undefinedToVoid` option.
    ///
    /// - Parameter value: Whether to enable `undefinedToVoid` option or not.
    @discardableResult
    @objc func undefinedToVoid(_ value: Bool) -> Self {
        return appending(key: "undefinedToVoid", value: value)
    }
}
