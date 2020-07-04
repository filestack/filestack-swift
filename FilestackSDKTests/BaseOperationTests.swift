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
    func testNotStartedOperation() throws {
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
            XCTFail("Should not fail.")
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
}
