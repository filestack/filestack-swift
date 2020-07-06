//
//  BaseOperationTests.swift
//  FilestackSDKTests
//
//  Created by Ruben Nine on 04/07/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import XCTest
@testable import FilestackSDK

class WorkOperation<R>: BaseOperation<R> {
    let block: ((WorkOperation) -> Void)

    required init(block: @escaping ((WorkOperation) -> Void)) {
        self.block = block
        super.init()
    }

    override func main() {
        block(self)
    }
}

func serialOperationQueue() -> OperationQueue {
    let queue = OperationQueue()

    queue.maxConcurrentOperationCount = 1

    return queue
}

class BaseOperationTests: XCTestCase {
    func testReadyOperation() throws {
        let operation = WorkOperation<Bool>() { _ in }

        // Assert flags
        XCTAssertEqual(operation.isReady, true)
        XCTAssertEqual(operation.isFinished, false)
        XCTAssertEqual(operation.isExecuting, false)
        XCTAssertEqual(operation.isCancelled, false)
    }

    func testFinishingOperation() throws {
        let queue = serialOperationQueue()
        let semaphore = DispatchSemaphore(value: 0)

        let operation = WorkOperation<Bool>() { work in
            Thread.sleep(forTimeInterval: 2)
            work.finish(with: .success(true))
            semaphore.signal()
        }

        // Enqueue operation and wait for task completion.
        queue.addOperation(operation)
        semaphore.wait()

        // Assert flags
        XCTAssertEqual(operation.isReady, true)
        XCTAssertEqual(operation.isExecuting, false)
        XCTAssertEqual(operation.isFinished, true)
        XCTAssertEqual(operation.isCancelled, false)

        // Assert that we got the expected `result`.
        switch operation.result {
        case let .success(result):
            XCTAssertEqual(result, true)
        case .failure(_):
            XCTFail()
        }
    }

    func testCancellingStartedOperation() throws {
        let queue = serialOperationQueue()
        let semaphore = DispatchSemaphore(value: 0)

        let operation = WorkOperation<Bool>() { work in
            Thread.sleep(forTimeInterval: 2)
            work.finish(with: .success(true))
        }

        // Assert that operation enters `executing` state after it is added to the queue.
        queue.addOperation(operation)
        _ = semaphore.wait(timeout: .now() + .milliseconds(500))

        // Assert flags
        XCTAssertEqual(operation.isReady, true)
        XCTAssertEqual(operation.isExecuting, true)
        XCTAssertEqual(operation.isFinished, false)
        XCTAssertEqual(operation.isCancelled, false)

        // Cancel ongoing operation.
        operation.cancel()

        // Assert flags
        XCTAssertEqual(operation.isReady, true)
        XCTAssertEqual(operation.isExecuting, false)
        XCTAssertEqual(operation.isFinished, true)
        XCTAssertEqual(operation.isCancelled, true)

        // Assert that we got the expected `result`.
        switch operation.result {
        case .success(_):
            XCTFail()
        case let .failure(error):
            XCTAssertEqual(error.localizedDescription, Error.cancelled.localizedDescription)
        }
    }

    func testCancellingNotStartedOperation() throws {
        let operation = WorkOperation<Bool>() { _ in }

        // Cancel ongoing operation.
        operation.cancel()

        // Assert flags
        XCTAssertEqual(operation.isReady, true)
        XCTAssertEqual(operation.isFinished, true)
        XCTAssertEqual(operation.isExecuting, false)
        XCTAssertEqual(operation.isCancelled, true)

        switch operation.result {
        case .success(_):
            XCTFail()
        case let .failure(error):
            XCTAssertEqual(error.localizedDescription, Error.cancelled.localizedDescription)
        }
    }

    func testObserversOnCancelledOperation() throws {
        let queue = serialOperationQueue()
        let semaphore = DispatchSemaphore(value: 0)

        let operation = WorkOperation<Bool>() { work in
            Thread.sleep(forTimeInterval: 5)
            work.finish(with: .success(true))
        }

        let isExecutingExpectation = self.expectation(description: "should change `isExecuting` to true")
        let isFinishedExpectation = self.expectation(description: "should change `isFinished` to true")
        let isCancelledExpectation = self.expectation(description: "should change `isCancelled` to true")

        var observers: [NSKeyValueObservation] = []

        observers.append(operation.observe(\.isExecuting, options: [.new]) { (operation, change) in
            if change.newValue == true {
                isExecutingExpectation.fulfill()
            }
        })

        observers.append(operation.observe(\.isFinished, options: [.new]) { (operation, change) in
            if change.newValue == true {
                isFinishedExpectation.fulfill()
            }
        })

        observers.append(operation.observe(\.isCancelled, options: [.new]) { (operation, change) in
            if change.newValue == true {
                isCancelledExpectation.fulfill()
            }
        })

        queue.addOperation(operation)
        _ = semaphore.wait(timeout: .now() + .milliseconds(500))

        // Cancel ongoing operation.
        operation.cancel()

        waitForExpectations(timeout: 15, handler: nil)
    }

    func testObserversOnFinishingOperation() throws {
        let queue = serialOperationQueue()

        let operation = WorkOperation<Bool>() { work in
            Thread.sleep(forTimeInterval: 1)
            work.finish(with: .success(true))
        }

        let isExecutingExpectation = self.expectation(description: "should change `isExecuting` to true")
        let isFinishedExpectation = self.expectation(description: "should change `isFinished` to true")

        var observers: [NSKeyValueObservation] = []

        observers.append(operation.observe(\.isExecuting, options: [.new]) { (operation, change) in
            if change.newValue == true {
                isExecutingExpectation.fulfill()
            }
        })

        observers.append(operation.observe(\.isFinished, options: [.new]) { (operation, change) in
            if change.newValue == true {
                isFinishedExpectation.fulfill()
            }
        })

        queue.addOperation(operation)

        waitForExpectations(timeout: 15, handler: nil)
    }
}
