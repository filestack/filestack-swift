//
//  UploadService.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/19/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Alamofire
import Foundation
import os.log

/// Service used for uploading files.
@objc(FSUploadService)
public final class UploadService: NSObject, NetworkingService {
    // MARK: - Internal Properties

    static private(set) var sessionManager = SessionManager.filestack(background: useBackgroundSession) {
        didSet {
            os_log("Background upload support is now %@.",
                   log: .uploads,
                   type: .info,
                   useBackgroundSession ? "enabled" : "disabled")
        }
    }

    // MARK: - Public Properties

    /// Whether uploads should be run on a background process. Defaults to `true`.
    static public var useBackgroundSession: Bool = true {
        didSet { sessionManager = .filestack(background: useBackgroundSession) }
    }

    // MARK: - Lifecycle

    private override init() {}
}

// MARK: - Internal Functions

extension UploadService {
    static func upload(multipartFormData: @escaping (MultipartFormData) -> Void,
                       url: URL,
                       queue: DispatchQueue = .main,
                       completionHandler: @escaping (JSONResponse) -> Void) {
        sessionManager.upload(multipartFormData: multipartFormData, to: url) { result in
            switch result {
            case let .success(request, _, _):
                request.responseJSON(queue: queue) { completionHandler(JSONResponse(with: $0)) }
            case let .failure(error):
                queue.async { completionHandler(JSONResponse(with: error)) }
            }
        }
    }

    static func upload(data: Data, to url: URLConvertible, method: HTTPMethod, headers: HTTPHeaders? = nil) -> UploadRequest? {
        if useBackgroundSession {
            if let dataURL = temporaryURL(using: data) {
                defer { try? FileManager.default.removeItem(at: dataURL) }
                return sessionManager.upload(dataURL, to: url, method: method, headers: headers)
            }

            return nil
        } else {
            return sessionManager.upload(data, to: url, method: method, headers: headers)
        }
    }
}

// MARK: - Private Functions

private extension UploadService {
    static func temporaryURL(using data: Data) -> URL? {
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
