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
    private var retrier: TaskRetrier<JSONResponse>?

    // MARK: - Lifecycle

    required init(partsAndEtags: [Int: String], descriptor: UploadDescriptor) {
        self.partsAndEtags = partsAndEtags
        self.descriptor = descriptor

        super.init()
    }

    // MARK: - BaseOperation Overrides

    override func finish(with result: BaseOperation<JSONResponse>.Result) {
        retrier = nil

        super.finish(with: result)
    }
}

// MARK: - Overrides

extension CompleteUploadOperation {
    override func main() {
        upload()
    }

    override func cancel() {
        super.cancel()

        retrier?.cancel()
    }
}

// MARK: - Private Functions

private extension CompleteUploadOperation {
    func upload() {
        let uploadURL = URL(string: "multipart/complete", relativeTo: Constants.uploadURL)!

        retrier = .init(attempts: Defaults.maxRetries, label: uploadURL.relativePath) { (semaphore) -> JSONResponse? in
            var jsonResponse: JSONResponse?

            UploadService.shared.upload(multipartFormData: self.multipartFormData, url: uploadURL) { response in
                jsonResponse = response
                semaphore.signal()
            }

            semaphore.wait()

            guard jsonResponse?.response?.statusCode == 200 else { return nil }

            return jsonResponse
        }

        if let response = retrier?.run() {
            finish(with: .success(response))
        } else {
            finish(with: .failure(.custom("Failed to complete /multipart/complete operation.")))
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

// MARK: - Defaults

private extension CompleteUploadOperation {
    struct Defaults {
        static let maxRetries = 5
    }
}
