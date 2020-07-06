//
//  SubmitPartRegularUploadOperation.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 26/09/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Alamofire
import Foundation

class SubmitPartRegularUploadOperation: BaseOperation<HTTPURLResponse>, SubmitPartUploadOperation {
    // MARK: - Internal Properties

    let number: Int
    let size: Int
    let offset: UInt64
    let descriptor: UploadDescriptor

    private(set) lazy var progress = Progress(totalUnitCount: Int64(size))

    // MARK: - Private Properties

    private var uploadRequest: UploadRequest?

    private lazy var data: Data = descriptor.reader.sync {
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
}

// MARK: - Operation Overrides

extension SubmitPartRegularUploadOperation {
    override func main() {
        let url = URL(string: "multipart/upload", relativeTo: Constants.uploadURL)!

        UploadService.upload(multipartFormData: multipartFormData, url: url, completionHandler: uploadDataChunk)
    }

    override func cancel() {
        super.cancel()

        uploadRequest?.cancel()
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

        guard let url = url(from: response),
              let headers = headers(from: response),
              let request = UploadService.upload(data: data, to: url, method: .put, headers: headers)
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
        form.append(descriptor.uri, named: "uri")
        form.append(descriptor.region, named: "region")
        form.append(descriptor.uploadID, named: "upload_id")
        form.append(String(data.count), named: "size")
        form.append(String(number), named: "part")
        form.append(data.base64MD5Digest(), named: "md5")

        descriptor.options.storeOptions.append(to: form)
    }
}
