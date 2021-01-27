//
//  SubmitPartRegularUploadOperation.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 26/09/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation

class SubmitPartRegularUploadOperation: BaseOperation<HTTPURLResponse>, SubmitPartUploadOperation {
    // MARK: - Internal Properties

    let number: Int
    let size: Int
    let offset: UInt64
    let descriptor: UploadDescriptor

    private(set) lazy var progress = Progress(totalUnitCount: Int64(size))

    // MARK: - Private Properties

    private var uploadTask: URLSessionUploadTask?

    private lazy var data: Data? = descriptor.reader.sync {
        descriptor.reader.seek(position: offset)

        return descriptor.reader.read(amount: size)
    }

    // MARK: - Lifecycle

    required init(number: Int, size: Int, offset: UInt64, descriptor: UploadDescriptor) {
        self.number = number
        self.size = size
        self.offset = offset
        self.descriptor = descriptor

        super.init()
    }

    override func finish(with result: BaseOperation<HTTPURLResponse>.Result) {
        data = nil

        super.finish(with: result)
    }
}

// MARK: - Operation Overrides

extension SubmitPartRegularUploadOperation {
    override func main() {
        let uploadURL = URL(string: "multipart/upload", relativeTo: Constants.uploadURL)!
        let headers = ["Content-Type": "application/json"]

        guard let payload = self.payload() else { return }

        UploadService.shared.upload(data: payload, to: uploadURL, method: "POST", headers: headers) { (data, response, error) in
            let jsonResponse = JSONResponse(response: response, data: data, error: error)
            self.uploadDataChunk(using: jsonResponse)
        }
    }

    override func cancel() {
        super.cancel()

        uploadTask?.cancel()
    }
}

// MARK: - Private Functions

private extension SubmitPartRegularUploadOperation {
    /// Extracts the URL from response.
    func url(from response: JSONResponse) -> URL? {
        guard let urlString = response.json?["url"] as? String else { return nil }

        return URL(string: urlString)
    }

    /// Extracts the headers from response.
    func headers(from response: JSONResponse) -> [String: String]? {
        return response.json?["headers"] as? [String: String]
    }

    /// Extracts the error from response.
    func error(from response: JSONResponse) -> String? {
        return response.json?["error"] as? String
    }

    /// Uploads the data chunk to the destination URL.
    func uploadDataChunk(using response: JSONResponse) {
        guard !isCancelled else { return }

        if let apiErrorDescription = error(from: response) {
            finish(with: .failure(.api(apiErrorDescription)))
            return
        }

        guard let data = data,
              let url = url(from: response),
              let headers = headers(from: response)
        else {
            finish(with: .failure(.unknown))
            return
        }

        uploadTask = UploadService.shared.upload(data: data, to: url, method: "PUT", headers: headers, uploadProgress: { (progress) in
            self.progress.totalUnitCount = Int64(data.size ?? 0)
            self.progress.completedUnitCount = Int64(Double(self.progress.totalUnitCount) * progress.fractionCompleted)
        }) { (_, response, error) in
            self.uploadTask = nil

            if let error = error {
                self.finish(with: .failure(.wrapped(error)))
            } else if let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200 {
                self.progress.completedUnitCount = self.progress.totalUnitCount
                self.finish(with: .success(httpURLResponse))
            } else {
                self.finish(with: .failure(.unknown))
            }
        }
    }

    func payload() -> Data? {
        guard let data = data else { return nil }

        let payload: [String: Any] = [
            "apikey": descriptor.config.apiKey,
            "uri": descriptor.uri,
            "region": descriptor.region,
            "upload_id": descriptor.uploadID,
            "part": number,
            "size": data.count,
            "md5": data.base64MD5Digest(),
            "store": descriptor.options.storeOptions.asDictionary()
        ]

        return try? JSONSerialization.data(withJSONObject: payload)
    }
}
