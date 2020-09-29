//
//  SubmitChunkUploadOperation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 8/2/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Alamofire
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

    private var uploadRequest: UploadRequest?

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
        let headers: HTTPHeaders = ["Content-Type": "application/json"]

        guard
            let payload = self.payload(),
            let request = UploadService.shared.upload(data: payload, to: uploadURL, method: .post, headers: headers)
        else {
            return
        }

        request.responseJSON { (response) in
            let jsonResponse = JSONResponse(with: response)
            self.uploadDataChunk(using: jsonResponse)
        }
    }

    override func cancel() {
        super.cancel()

        uploadRequest?.cancel()
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
            let headers = headers(from: response),
            let request = UploadService.shared.upload(data: data, to: url, method: .put, headers: headers)
        else {
            finish(with: .failure(.unknown))
            return
        }

        // Handle upload progress update.
        request.uploadProgress {
            self.progress.totalUnitCount = $0.totalUnitCount
            self.progress.completedUnitCount = $0.completedUnitCount
        }

        // Handle request response.
        request.response { response in
            self.uploadRequest = nil

            if let error = response.error {
                self.finish(with: .failure(.wrapped(error)))
            } else if let httpURLResponse = response.response, httpURLResponse.statusCode == 200 {
                self.progress.completedUnitCount = self.progress.totalUnitCount
                self.finish(with: .success(httpURLResponse))
            } else {
                self.finish(with: .failure(.unknown))
            }
        }

        uploadRequest = request
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
