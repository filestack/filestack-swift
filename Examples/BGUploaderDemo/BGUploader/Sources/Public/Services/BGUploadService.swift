//
//  BGUploadService.swift
//  BGUploader
//
//  Created by Ruben Nine on 20/10/21.
//

import Foundation
import FilestackSDK

public protocol BGUploadServiceDelegate: AnyObject {
    /// Called after an upload task completes (either successfully or failing.)
    ///
    /// You may query `url` to determine the file `URL` that was uploaded and `status` to determine completion status
    /// on the returned `BackgroundUploadTaskResult` object.
    func uploadService(_ uploadService: BGUploadService, didCompleteWith result: BackgroundUploadTaskResult)
}

public class BGUploadService: NSObject {
    // MARK: - Public Properties

    public let backgroundIdentifer = "com.filestack.BGUploader"
    public weak var delegate: BGUploadServiceDelegate?

    // MARK: - Private Properties

    private let storeURL = URL(string: "https://www.filestackapi.com/api/store/S3")!
    private var transitorySessionData = [URLSessionTask: Data]()
    private let fsClient: Client

    private lazy var session: URLSession = {
        let configuration: URLSessionConfiguration

        configuration = .background(withIdentifier: backgroundIdentifer)
        configuration.isDiscretionary = false
        configuration.waitsForConnectivity = true

        return URLSession(configuration: configuration, delegate: self, delegateQueue: .main)
    }()

    // MARK: - Lifecycle

    public init(fsClient: Client) {
        self.fsClient = fsClient
    }
}

// MARK: - URLSessionDataDelegate Protocol Implementation

extension BGUploadService: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        transitorySessionData[dataTask] = data
    }
}

// MARK: - URLSessionTaskDelegate Protocol Implementation

extension BGUploadService: URLSessionTaskDelegate {
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Swift.Error?) {
        guard let result = UserDefaults.backgroundUploadProcess.tasks[task.taskIdentifier] else { return }

        if task.state == .completed, let responseData = transitorySessionData[task] {
            transitorySessionData.removeValue(forKey: task)

            do {
                let storeResponse = try JSONDecoder().decode(StoreResponse.self, from: responseData)
                result.status = .completed(response: storeResponse)
            } catch {
                result.status = .failed(error: .undecodableJSONResponse)
            }
        } else if let error = error {
            result.status = .failed(error: .other(description: error.localizedDescription))
        } else {
            result.status = .failed(error: .unknown)
        }

        delegate?.uploadService(self, didCompleteWith: result)
        removeTaskResult(with: task.taskIdentifier)
    }
}

// MARK: - BGUploadService Error

public extension BGUploadService {
    enum Error: Swift.Error, Equatable, Codable {
        case undecodableJSONResponse
        case other(description: String)
        case unknown
    }
}

// MARK: - Public Functions

public extension BGUploadService {
    /// Uploads an `URL` to Filestack using a background `URLSession`.
    @discardableResult
    func upload(url: URL) -> URLSessionUploadTask? {
        let task = session.uploadTask(with: storeRequest(for: url), fromFile: url)

        addTaskResult(with: task.taskIdentifier, for: url)

        task.resume()

        return task
    }

    /// Resumes any pending background uploads.
    ///
    /// Call this function on your `AppDelegate.application(_:,handleEventsForBackgroundURLSession:,completionHandler:)`
    func resumePendingUploads(completionHandler: @escaping () -> Void) {
        session.getAllTasks { tasks in
            for task in tasks {
                task.resume()
            }

            completionHandler()
        }
    }
}

// MARK: - Private Functions

private extension BGUploadService {
    /// Returns an `URLRequest` setup for uploading a file using
    /// Filestack's [Basic Uploads](https://www.filestack.com/docs/uploads/uploading/#basic-uploads) API.
    func storeRequest(for url: URL) -> URLRequest {
        var components = URLComponents(url: storeURL, resolvingAgainstBaseURL: false)!
        var queryItems: [URLQueryItem] = []

        queryItems = [
            URLQueryItem(name: "key", value: fsClient.apiKey),
            URLQueryItem(name: "filename", value: url.filename)
        ]

        if let security = fsClient.security {
            queryItems.append(URLQueryItem(name: "policy", value: security.encodedPolicy))
            queryItems.append(URLQueryItem(name: "signature", value: security.signature))
        }

        components.queryItems = queryItems

        var request = URLRequest(url: components.url!)

        request.addValue(url.mimeType ?? "text/plain", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"

        return request
    }

    @discardableResult
    func addTaskResult(with taskIdentifier: Int, for url: URL) -> BackgroundUploadTaskResult {
        let taskResult = BackgroundUploadTaskResult(url: url)
        UserDefaults.backgroundUploadProcess.tasks[taskIdentifier] = taskResult
        return taskResult
    }

    @discardableResult
    private func removeTaskResult(with taskIdentifier: Int) -> BackgroundUploadTaskResult? {
        return UserDefaults.backgroundUploadProcess.tasks.removeValue(forKey: taskIdentifier)
    }
}
