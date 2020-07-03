//
//  CompleteUploadOperation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/25/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Alamofire
import Foundation

class CompleteUploadOperation: BaseOperation<JSONResponse> {
    // MARK: - Private Properties

    private let partsAndEtags: [Int: String]
    private let descriptor: UploadDescriptor
    private let retries: Int

    // MARK: - Lifecycle

    required init(partsAndEtags: [Int: String], retries: Int, descriptor: UploadDescriptor) {
        self.partsAndEtags = partsAndEtags
        self.retries = retries
        self.descriptor = descriptor

        super.init()

        state = .ready
    }
}

// MARK: - Overrides

extension CompleteUploadOperation {
    override func main() {
        upload()
    }
}

// MARK: - Private Functions

private extension CompleteUploadOperation {
    func upload() {
        let uploadURL = URL(string: "multipart/complete", relativeTo: Constants.uploadURL)!

        let retrier = TaskRetrier<JSONResponse>(attempts: retries, label: uploadURL.relativePath) { (retrier) -> JSONResponse? in
            let semaphore = DispatchSemaphore(value: 0)
            var jsonResponse: JSONResponse?

            UploadService.upload(multipartFormData: self.multipartFormData, url: uploadURL) { response in
                jsonResponse = response
                semaphore.signal()
            }

            semaphore.wait()

            // Guard against operation cancellation.
            guard !self.isCancelled else {
                retrier.cancel()
                return nil
            }

            // Validate response.
            let isWrongStatusCode = jsonResponse?.response?.statusCode != 200
            let isNetworkError = jsonResponse?.response == nil

            // Check for any error response
            if jsonResponse == nil || isWrongStatusCode || isNetworkError {
                return nil
            } else {
                return jsonResponse
            }
        }

        if let response = retrier.run() {
            finish(with: .success(response))
        } else {
            finish(with: .failure(Error.custom("Failed to complete upload operation.")))
        }
    }

    func multipartFormData(form: MultipartFormData) {
        form.append(descriptor.config.apiKey, named: "apikey")
        form.append(descriptor.uri, named: "uri")
        form.append(descriptor.region, named: "region")
        form.append(descriptor.uploadID, named: "upload_id")
        form.append(descriptor.filename, named: "filename")
        form.append(String(descriptor.filesize), named: "size")
        form.append(descriptor.mimeType, named: "mimetype")

        descriptor.options.storeOptions.append(to: form)

        if let security = descriptor.config.security {
            form.append(security.encodedPolicy, named: "policy")
            form.append(security.signature, named: "signature")
        }

        if descriptor.useIntelligentIngestion {
            form.append("true", named: "multipart")
        } else {
            let parts = (partsAndEtags.map { "\($0.key):\($0.value)" }).joined(separator: ";")
            form.append(parts, named: "parts")
        }
    }
}
