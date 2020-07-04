//
//  BaseOperation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/19/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Alamofire
import Foundation

class BaseOperation<Success>: Operation {
    typealias Result = Swift.Result<Success, Swift.Error>

    // MARK: - Private Properties

    private var lockQueue = DispatchQueue(label: "lock-queue")

    private var _result: Result = .failure(Error.unknown)

    private var _state = State.ready {
        willSet {
            willChangeValue(forKey: _state.description)
            willChangeValue(forKey: newValue.description)
        }

        didSet {
            didChangeValue(forKey: oldValue.description)
            didChangeValue(forKey: _state.description)
        }
    }

    // MARK: - Operation Overrides

    override var isReady: Bool { _state == .ready }
    override var isExecuting: Bool { _state == .executing }
    override var isFinished: Bool { _state == .finished }

    override func start() {
        state = .executing

        guard !isCancelled else {
            state = .finished
            return
        }

        main()
    }

    override func cancel() {
        finish(with: .failure(Error.cancelled))

        super.cancel()
    }

    // MARK: - Internal Functions

    func finish(with result: Result) {
        self.result = result
        state = .finished
    }
}

// MARK: - Synchronized Properties

extension BaseOperation {
    private(set) var result: Result {
        get { lockQueue.sync { _result } }
        set { lockQueue.sync { _result = newValue } }
    }

    var state: State {
        get { lockQueue.sync { _state } }
        set { lockQueue.sync { _state = newValue } }
    }
}

// MARK: - State

extension BaseOperation {
    enum State {
        case ready
        case executing
        case finished
    }
}

// MARK: - CustomStringConvertible Conformance

extension BaseOperation.State: CustomStringConvertible {
    var description: String {
        switch self {
        case .ready: return "isReady"
        case .executing: return "isExecuting"
        case .finished: return "isFinished"
        }
    }
}
