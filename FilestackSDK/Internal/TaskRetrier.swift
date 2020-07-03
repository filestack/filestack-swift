//
//  TaskRetrier.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 01/07/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import Foundation
import os.log

enum BackoffStrategy {
    case fixed(seconds: Int)
    case linear
    case exponential
}

/// Encapsulates a mechanism that retries a task with configurable attempts and backoff strategy.
///
/// Task is assumed to have succeeded if the task block returns `Result`, however if it receives `nil`, it will keep
/// retrying using the configured the backoff strategy.
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
    /// User should call `semaphore.signal()` after result is received and assigned and `semaphore.wait()` before
    /// returning the value.
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
                stopWatch.signalComplete()
                return result
            } else {
                stopWatch.signalFail()
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
        private var attempts: Int = 0

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
        guard let owner = owner else { return }

        start = CACurrentMediaTime()

        os_log("Started task \"%@\" %@.",
               log: .retrier,
               type: .debug,
               owner.label, owner.uuid.uuidString)
    }

    /// Signals attempt failed.
    mutating func signalFail() {
        guard let owner = owner, let elapsedTime = getElapsedTime() else { return }

        attempts += 1

        os_log("Failed to complete task \"%@\" (%@) started %.2fs ago. Attempt %d of %d.",
               log: .retrier,
               type: .debug,
               owner.label, owner.uuid.uuidString, elapsedTime, attempts, owner.attempts)
    }

    /// Signals task completion.
    mutating func signalComplete() {
        guard let owner = owner, let elapsedTime = getElapsedTime() else { return }

        attempts += 1

        os_log("Completed task \"%@\" (%@) in %.2fs after %d attempts.",
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
