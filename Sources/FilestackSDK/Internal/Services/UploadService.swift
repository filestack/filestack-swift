//
//  UploadService.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/19/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import os.log

private let Shared = UploadService()

// Provides synchronized access to task data and completion handlers.
struct TaskState {
    typealias CompletionHandler = (Data?, URLResponse?, Swift.Error?) -> Void

    private var taskData: [URLSessionDataTask: Data] = [:]
    private var taskCompletion: [URLSessionDataTask: CompletionHandler] = [:]
    private let syncQueue = DispatchQueue(label: "io.filestack.TaskState-sync-queue")

    func getData(for task: URLSessionDataTask) -> Data? {
        syncQueue.sync { taskData[task] }
    }

    mutating func setData(for task: URLSessionDataTask, data: Data) {
        syncQueue.sync { taskData[task] = data }
    }

    func getCompletion(for task: URLSessionDataTask) -> CompletionHandler? {
        syncQueue.sync { taskCompletion[task] }
    }

    mutating func setCompletionHandler(for task: URLSessionDataTask, completionHandler: @escaping CompletionHandler) {
        syncQueue.sync { taskCompletion[task] = completionHandler }
    }

    mutating func forget(task: URLSessionDataTask) {
        syncQueue.sync {
            taskData.removeValue(forKey: task)
            taskCompletion.removeValue(forKey: task)
        }
    }
}


/// Service used for uploading files.
@objc(FSUploadService)
public final class UploadService: NSObject, NetworkingService {
    // MARK: - Internal Properties

    private(set) internal lazy var session = URLSession.filestack(background: useBackgroundSession, delegate: self)

    // MARK: - Private Properties

    private var taskState = TaskState()

    // MARK: - Public Properties

    /// Shared `UploadService` instance.
    public static let shared = Shared

    /// Whether uploads should be performed on a background process. Defaults to `false`.
    public var useBackgroundSession: Bool = false {
        didSet {
            session = .filestack(background: useBackgroundSession, delegate: self)

            os_log("Background upload support is now %@.",
                   log: .uploads,
                   type: .info,
                   useBackgroundSession ? "enabled" : "disabled")
        }
    }

    // MARK: - Lifecycle

    fileprivate override init() {}
}

// MARK: - URLSessionDataDelegate Conformance

extension UploadService: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        completionHandler(URLSession.ResponseDisposition .allow)

        if response.expectedContentLength == 0 || dataTask.error != nil {
            let completionHandler = taskState.getCompletion(for: dataTask)

            taskState.forget(task: dataTask)

            DispatchQueue.main.async {
                completionHandler?(nil, response, dataTask.error)
            }
        }
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if var existingData = taskState.getData(for: dataTask) {
            existingData.append(data)
            taskState.setData(for: dataTask, data: existingData)
        } else {
            taskState.setData(for: dataTask, data: data)
        }

        if let response = dataTask.response {
            let data = taskState.getData(for: dataTask)
            let completionHandler = taskState.getCompletion(for: dataTask)

            taskState.forget(task: dataTask)

            DispatchQueue.main.async {
                completionHandler?(data, response, dataTask.error)
            }
        }
    }
}

// MARK: - Internal Functions

extension UploadService {
    @discardableResult
    func upload(data: Data,
                to url: URL,
                method: String,
                headers: [String: String]? = nil,
                uploadProgress: ((Progress) -> Void)? = nil,
                completionHandler: @escaping (Data?, URLResponse?, Swift.Error?) -> Void) -> URLSessionUploadTask? {
        var request = URLRequest(url: url)

        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        request.networkServiceType = .responsiveData

        let task: URLSessionUploadTask

        if useBackgroundSession {
            guard let dataURL = temporaryURL(using: data) else { return nil }
            defer { try? FileManager.default.removeItem(at: dataURL) }

            task = session.uploadTask(with: request, fromFile: dataURL)

            taskState.setCompletionHandler(for: task, completionHandler: completionHandler)
        } else {
            task = session.uploadTask(with: request, from: data) { (data, response, error) in
                DispatchQueue.main.async {
                    completionHandler(data, response, error)
                }
            }
        }

        if let uploadProgress = uploadProgress {
            var progressObservers: [NSKeyValueObservation] = []

            progressObservers.append(task.progress.observe(\.fractionCompleted) { progress, _ in
                DispatchQueue.main.async {
                    uploadProgress(progress)

                    if progress.isFinished || progress.isCancelled {
                        progressObservers.removeAll()
                    }
                }
            })
        }

        task.resume()

        return task
    }
}

// MARK: - Private Functions

private extension UploadService {
    func temporaryURL(using data: Data) -> URL? {
        let temporaryDirectoryURL = FileManager.default.temporaryDirectory
        let dataURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString)

        do {
            try data.write(to: dataURL)

            return dataURL
        } catch {
            os_log("Unable to create temporary data file at %@",
                   log: .uploads,
                   type: .fault,
                   dataURL.description)

            return nil
        }
    }
}
