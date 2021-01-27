//
//  CommitPartUploadOperation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/31/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

class CommitPartUploadOperation: BaseOperation<HTTPURLResponse> {
    // MARK: - Private Properties

    private let descriptor: UploadDescriptor
    private let part: Int
    private var retrier: TaskRetrier<HTTPURLResponse>?

    // MARK: - Lifecyle

    required init(descriptor: UploadDescriptor, part: Int) {
        self.descriptor = descriptor
        self.part = part

        super.init()
    }

    // MARK: - BaseOperation Overrides

    override func finish(with result: BaseOperation<HTTPURLResponse>.Result) {
        retrier = nil

        super.finish(with: result)
    }
}

// MARK: - Overrides

extension CommitPartUploadOperation {
    override func main() {
        upload()
    }

    override func cancel() {
        super.cancel()

        retrier?.cancel()
    }
}

// MARK: - Private Functions

private extension CommitPartUploadOperation {
    func upload() {
        let uploadURL = URL(string: "multipart/commit", relativeTo: Constants.uploadURL)!

        retrier = .init(attempts: Defaults.maxRetries, label: uploadURL.relativePath) { (semaphore) -> HTTPURLResponse? in
            var httpURLResponse: HTTPURLResponse?
            let headers = ["Content-Type": "application/json"]

            guard let payload = self.payload() else { return nil }

            UploadService.shared.upload(data: payload, to: uploadURL, method: "POST", headers: headers) { (data, response, error) in
                httpURLResponse = response as? HTTPURLResponse
                semaphore.signal()
            }

            semaphore.wait()

            guard httpURLResponse?.statusCode == 200 else { return nil }

            return httpURLResponse
        }

        if let response = retrier?.run() {
            finish(with: .success(response))
        } else {
            finish(with: .failure(.custom("Unable to complete /multipart/commit operation.")))
        }
    }

    func payload() -> Data? {
        var payload: [String: Any] = [
            "apikey": descriptor.config.apiKey,
            "uri": descriptor.uri,
            "region": descriptor.region,
            "upload_id": descriptor.uploadID,
            "size": descriptor.filesize,
            "part": part,
            "store": descriptor.options.storeOptions.asDictionary()
        ]

        if descriptor.useIntelligentIngestion {
            payload["fii"] = true
        }

        return try? JSONSerialization.data(withJSONObject: payload)
    }
}

// MARK: - Defaults

private extension CommitPartUploadOperation {
    struct Defaults {
        static let maxRetries = 5
    }
}
