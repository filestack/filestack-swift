//
//  SubmitChunkUploadOperation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 8/2/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

class SubmitChunkUploadOperation: BaseOperation<HTTPURLResponse> {
    // MARK: - Internal Properties

    // Part offset
    let partOffset: UInt64
    // Chunk offset
    let offset: UInt64
    // Part number
    let part: Int
    // Chunk size
    let size: Int
    // Uploader descriptor
    let descriptor: UploadDescriptor

    private(set) lazy var progress: Progress = Progress(totalUnitCount: Int64(data.count))

    // MARK: - Private Properties

    private var uploadTask: URLSessionUploadTask?

    private lazy var data: Data = descriptor.reader.sync {
        descriptor.reader.seek(position: partOffset + offset)

        return descriptor.reader.read(amount: size)
    }

    // MARK: - Lifecycle

    required init(partOffset: UInt64, offset: UInt64, size: Int, part: Int, descriptor: UploadDescriptor) {
        self.partOffset = partOffset
        self.offset = offset
        self.part = part
        self.size = size
        self.descriptor = descriptor

        super.init()
    }
}

// MARK: - Overrides

extension SubmitChunkUploadOperation {
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

private extension SubmitChunkUploadOperation {
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

        guard
            let url = url(from: response),
            let headers = headers(from: response)
        else {
            finish(with: .failure(.unknown))
            return
        }

        uploadTask = UploadService.shared.upload(data: data, to: url, method: "PUT", headers: headers, uploadProgress: { (progress) in
            self.progress.totalUnitCount = Int64(self.data.size ?? 0)
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
        let payload: [String: Any] = [
            "apikey": descriptor.config.apiKey,
            "uri": descriptor.uri,
            "region": descriptor.region,
            "upload_id": descriptor.uploadID,
            "part": part,
            "size": data.count,
            "md5": data.base64MD5Digest(),
            "offset": offset,
            "fii": true,
            "store": descriptor.options.storeOptions.asDictionary()
        ]

        return try? JSONSerialization.data(withJSONObject: payload)
    }
}
