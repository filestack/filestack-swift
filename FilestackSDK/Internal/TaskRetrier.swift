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
    case fixed(seconds: Double)
    case linear
    case exponential
}

/// Encapsulates a mechanism that retries a task with configurable attempts and backoff strategy.
///
/// Task is assumed to have succeeded if the task block returns `Result`, however if it receives `nil`, it will keep
/// retrying using the configured the backoff strategy.
class TaskRetrier<Result> {
    private let uuid = UUID()
    private let attempts: Int
    private let strategy: BackoffStrategy
    private let block: (TaskRetrier) -> Result?
    private let label: String
    private var shouldCancel: Bool = false

    init(attempts: Int, strategy: BackoffStrategy = .exponential, label: String, task block: @escaping (TaskRetrier) -> Result?) {
        self.attempts = attempts
        self.strategy = strategy
        self.label = label
        self.block = block
    }

    /// Starts executing and retries until success using the configured backoff strategy.
    ///
    /// - Note: Should not be called on the main thread.
    func run() -> Result? {
        let startTime = CACurrentMediaTime()

        os_log("Started task \"%@\" %@.",
               log: .retrier,
               type: .debug,
               label, uuid.uuidString)

        for attempt in 1...attempts {
            guard !shouldCancel else { break }

            if let result = block(self) {
                let endTime = CACurrentMediaTime()
                let elapsedTime = endTime - startTime

                os_log("Completed task \"%@\" (%@) in %.2fs after %d attempts.",
                       log: .retrier,
                       type: .debug,
                       label, uuid.uuidString, elapsedTime, attempt)

                return result
            } else {
                os_log("Failed to complete task \"%@\" (%@). Attempt %d of %d.",
                       log: .retrier,
                       type: .debug,
                       label, uuid.uuidString, attempt, attempts)
            }

            // Determine sleep time, depending on strategy.
            let delay: Double

            switch strategy {
            case let .fixed(seconds): delay = seconds
            case .linear: delay = Double(attempt)
            case .exponential: delay = pow(2, Double(attempt - 1)) // start at 2^0 (1 sec)
            }

            // Sleep for `delay` seconds.
            Thread.sleep(forTimeInterval: delay)
        }

        return nil
    }

    /// Marks the retrying execution as cancelled.
    func cancel() {
        shouldCancel = true
    }
}
