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

        UploadService.shared.upload(multipartFormData: multipartFormData, url: uploadURL, completionHandler: uploadDataChunk)
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

        guard let url = url(from: response),
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

    /// Encode multipart form data.
    func multipartFormData(form: MultipartFormData) {
        form.append(descriptor.config.apiKey, named: "apikey")
        form.append(String(part), named: "part")
        form.append(String(data.count), named: "size")
        form.append(data.base64MD5Digest(), named: "md5")
        form.append(descriptor.uri, named: "uri")
        form.append(descriptor.region, named: "region")
        form.append(descriptor.uploadID, named: "upload_id")
        form.append("true", named: "multipart")
        form.append(String(offset), named: "offset")
    }
}
