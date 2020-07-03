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

    var result: Result = .failure(Error.unknown)

    var state = State.ready {
        willSet {
            willChangeValue(forKey: state.description)
            willChangeValue(forKey: newValue.description)
        }

        didSet {
            didChangeValue(forKey: oldValue.description)
            didChangeValue(forKey: state.description)
        }
    }

    // MARK: - Operation Overrides

    override var isReady: Bool { state == .ready }
    override var isExecuting: Bool { state == .executing }
    override var isFinished: Bool { state == .finished }

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
