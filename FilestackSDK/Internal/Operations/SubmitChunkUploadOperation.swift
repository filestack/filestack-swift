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

    let data: Data
    let offset: UInt64
    let part: Int
    let descriptor: UploadDescriptor

    private(set) lazy var progress: Progress = Progress(totalUnitCount: Int64(data.count))

    // MARK: - Private Properties

    private var uploadRequest: UploadRequest?

    // MARK: - Lifecycle

    required init(data: Data, offset: UInt64, part: Int, descriptor: UploadDescriptor) {
        self.data = data
        self.offset = offset
        self.part = part
        self.descriptor = descriptor

        super.init()
    }

    // MARK - BaseOperation Overrides

    override func finish(with result: BaseOperation<HTTPURLResponse>.Result) {
        super.finish(with: result)

        uploadRequest = nil
    }
}

// MARK: - Overrides

extension SubmitChunkUploadOperation {
    override func main() {
        let uploadURL = URL(string: "multipart/upload", relativeTo: Constants.uploadURL)!

        UploadService.upload(multipartFormData: multipartFormData, url: uploadURL, completionHandler: uploadDataChunk)
    }

    override func cancel() {
        uploadRequest?.cancel()

        super.cancel()
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

    /// Uploads the data chunk to the destination URL.
    func uploadDataChunk(using response: JSONResponse) {
        guard !isCancelled else { return }

        guard let url = url(from: response),
              let headers = headers(from: response),
              let uploadRequest = UploadService.upload(data: data, to: url, method: .put, headers: headers)
        else {
            self.finish(with: .failure(Error.unknown))
            return
        }

        self.uploadRequest = uploadRequest

        /// Handle upload progress update.
        uploadRequest.uploadProgress {
            self.progress.totalUnitCount = $0.totalUnitCount
            self.progress.completedUnitCount = $0.completedUnitCount
        }

        /// Handle request response.
        uploadRequest.response { response in
            DispatchQueue.main.async {
                if let httpURLResponse = response.response {
                    self.finish(with: .success(httpURLResponse))
                } else {
                    self.finish(with: .failure(response.error ?? Error.unknown))
                }
            }
        }
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
