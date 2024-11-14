//
//  BaseOperation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/19/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

/// An operation that simplifies state flag handling and provides a method to finish a task delivering a `result`
/// containing either a `Success` response or an `Error` response.
///
/// State behavior:
///
/// - The operation, regardless of state, will always return `isReady` true.
/// - An executing operation will return `isExecuting` true.
/// - A finished operation will return `isFinished` true.
/// - A cancelled operation will return `isCancelled` true.
open class BaseOperation<Success>: Operation, @unchecked Sendable {
    public typealias Result = Swift.Result<Success, Error>

    // MARK: - Private Properties

    private let lockQueue = DispatchQueue(label: "com.filestack.FilestackSDK.operation-lock-queue")

    private var _result: Result = .failure(.custom("Result not unavailable."))

    private var _state = State.ready {
        willSet {
            guard _state != newValue else { return }

            if newValue == .ready { willChangeValue(for: \.isReady) }
            willChangeValue(for: \.isExecuting)
            willChangeValue(for: \.isFinished)
        }

        didSet {
            guard _state != oldValue else { return }

            if _state == .ready { didChangeValue(for: \.isReady) }
            didChangeValue(for: \.isExecuting)
            didChangeValue(for: \.isFinished)
        }
    }

    // MARK: - Property Overrides

    open override var isReady: Bool { _state.contains(.ready) }
    open override var isExecuting: Bool { _state == .executing }
    open override var isFinished: Bool { _state == .finished }

    // MARK: - Function Overrides

    open override func start() {
        state = .executing

        if !isCancelled { main() }
    }

    open override func cancel() {
        super.cancel()

        finish(with: .failure(.cancelled))
    }

    // MARK: - Open Functions

    open func finish(with result: Result) {
        self.result = result

        if state == .ready {
            state = .executing
        }

        state = .finished
    }
}

// MARK: - Synchronized Properties

extension BaseOperation {
    /// Returns the result of operation.
    open private(set) var result: Result {
        get { lockQueue.sync { _result } }
        set { lockQueue.sync { _result = newValue } }
    }

    private var state: State {
        get { lockQueue.sync { _state } }
        set { lockQueue.sync { _state = newValue } }
    }
}

// MARK: - State

private struct State: OptionSet {
    let rawValue: Int

    // Ready state.
    static let ready = Self(rawValue: 1 << 0)

    // Executing state (implies `ready` is also true.)
    static let executing: Self = [.ready, .init(rawValue: 1 << 1)]

    // Finished state (implies `ready` is also true.)
    static let finished: Self = [.ready, .init(rawValue: 1 << 2)]
}
