//
//  TaskRetrier.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 01/07/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import Foundation
import QuartzCore
import os.log

enum BackoffStrategy {
    case fixed(seconds: Int)
    case linear
    case exponential
}

/// Encapsulates a mechanism that retries a task with configurable attempts and backoff strategy.
///
/// Task is assumed to have succeeded if the task block returns `Result`, however if it receives `nil`, it will keep
/// retrying using the configured backoff strategy.
class TaskRetrier<Result> {
    // MARK: - Internal Properties

    let uuid = UUID()
    let label: String
    let attempts: Int
    let strategy: BackoffStrategy

    // MARK: - Private Properties

    private let block: (DispatchSemaphore) -> Result?
    private let runQueue = DispatchQueue(label: "com.filestack.FilestackSDK.task-run")
    private var semaphore = DispatchSemaphore(value: 0)
    private lazy var stopWatch = StopWatch(owner: self)

    private var shouldCancel: Bool = false {
        didSet {
            if shouldCancel { semaphore.signal() }
        }
    }

    // MARK: - Lifecycle

    init(attempts: Int, strategy: BackoffStrategy = .exponential, label: String, task block: @escaping (DispatchSemaphore) -> Result?) {
        self.attempts = attempts
        self.strategy = strategy
        self.label = label
        self.block = block
    }

    /// Starts executing and retries until success using the configured backoff strategy.
    ///
    /// User should call `semaphore.wait()` while waiting for the return value, and, `semaphore.signal()` after result
    /// is obtained.
    func run() -> Result? {
        runQueue.sync { doRun() }
    }

    /// Marks the retrying execution as cancelled.
    func cancel() {
        shouldCancel = true
    }
}

// MARK - Private Functions

private extension TaskRetrier {
    func doRun() -> Result? {
        stopWatch.signalStart()

        for attempt in 1...attempts {
            guard !shouldCancel else { break }

            if let result = block(semaphore) {
                stopWatch.signalComplete(attempts: attempt)
                return result
            } else {
                stopWatch.signalFail(attempts: attempt)
            }

            // Determine wait time, depending on strategy.
            let interval: DispatchTimeInterval

            switch strategy {
            case let .fixed(seconds): interval = .seconds(seconds)
            case .linear: interval = .seconds(attempt)
            case .exponential: interval = .seconds(Int(pow(2, Double(attempt - 1)))) // start at 2^0 (1 sec)
            }

            _ = semaphore.wait(timeout: .now() + interval)
        }

        return nil
    }
}

// MARK: - StopWatch Implementation

private extension TaskRetrier {
    /// Simple stop watch implementation for `TaskRetrier` with incorporated logging.
    struct StopWatch {
        // MARK: - Private Properties

        private var start: CFTimeInterval?
        private var end: CFTimeInterval?

        private weak var owner: TaskRetrier<Result>?

        // MARK: - Lifecycle

        init(owner: TaskRetrier<Result>?) {
            self.owner = owner
        }
    }
}

// MARK: - Private Functions

private extension TaskRetrier.StopWatch {
    /// Signals task start.
    mutating func signalStart() {
        start = CACurrentMediaTime()

        guard let owner = owner else { return }

        os_log("Started task \"%@\" %@.",
               log: .retrier,
               type: .debug,
               owner.label, owner.uuid.uuidString)
    }

    /// Signals failed attempt.
    mutating func signalFail(attempts: Int) {
        guard let owner = owner, let elapsedTime = getElapsedTime() else { return }

        os_log("Failed to complete task \"%@\" (%@) started %.2fs ago. Attempt %d of %d.",
               log: .retrier,
               type: .debug,
               owner.label, owner.uuid.uuidString, elapsedTime, attempts, owner.attempts)
    }

    /// Signals task complete.
    mutating func signalComplete(attempts: Int) {
        guard let owner = owner, let elapsedTime = getElapsedTime() else { return }

        os_log("Completed task \"%@\" (%@) in %.2fs after %d attempt(s).",
               log: .retrier,
               type: .debug,
               owner.label, owner.uuid.uuidString, elapsedTime, attempts)
    }

    /// Gets the elapsed time since task was started (if started.)
    mutating func getElapsedTime() -> CFTimeInterval? {
        end = CACurrentMediaTime()

        if let start = start, let end = end {
            return end - start
        } else {
            return 0
        }
    }
}
