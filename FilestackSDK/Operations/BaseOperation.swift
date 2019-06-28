//
//  BaseOperation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/19/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Alamofire
import Foundation

class BaseOperation: Operation {
    enum State {
        case ready
        case executing
        case finished

        var key: String {
            switch self {
            case .ready:
                return "isReady"
            case .executing:
                return "isExecuting"
            case .finished:
                return "isFinished"
            }
        }
    }

    var state = State.ready {
        willSet {
            willChangeValue(forKey: state.key)
            willChangeValue(forKey: newValue.key)
        }
        didSet {
            didChangeValue(forKey: oldValue.key)
            didChangeValue(forKey: state.key)
        }
    }

    override var isReady: Bool {
        return state == .ready
    }

    override var isExecuting: Bool {
        return state == .executing
    }

    override var isFinished: Bool {
        return state == .finished
    }
}

struct MultipartResponse {
    let response: HTTPURLResponse?
    let error: Error?
    let etag: String?
}

extension MultipartFormData {
    func append(_ string: String?, withName name: String) {
        guard let data = string?.data(using: .utf8) else { return }
        append(data, withName: name)
    }
}
