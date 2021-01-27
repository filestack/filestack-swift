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

/// Service used for uploading files.
@objc(FSUploadService)
public final class UploadService: NSObject, NetworkingService {
    // MARK: - Internal Properties

    private(set) internal lazy var session = URLSession.filestack(background: useBackgroundSession, delegate: self)

    // MARK: - Private Properties

    private var taskData: [URLSessionDataTask: Data] = [:]
    private var taskCompletion: [URLSessionDataTask: (Data?, URLResponse?, Swift.Error?) -> Void] = [:]

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
            let completionHandler = taskCompletion[dataTask]

            taskData.removeValue(forKey: dataTask)
            taskCompletion.removeValue(forKey: dataTask)

            DispatchQueue.main.async {
                completionHandler?(nil, response, dataTask.error)
            }
        }
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if var existingData = taskData[dataTask] {
            existingData.append(data)
            taskData[dataTask] = existingData
        } else {
            taskData[dataTask] = data
        }

        if let response = dataTask.response {
            let data = taskData[dataTask]
            let completionHandler = taskCompletion[dataTask]

            taskData.removeValue(forKey: dataTask)
            taskCompletion.removeValue(forKey: dataTask)

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

        let task: URLSessionUploadTask

        if useBackgroundSession {
            guard let dataURL = temporaryURL(using: data) else { return nil }
            defer { try? FileManager.default.removeItem(at: dataURL) }

            task = session.uploadTask(with: request, fromFile: dataURL)
        } else {
            task = session.uploadTask(with: request, from: data)
        }

        taskCompletion[task] = completionHandler

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
