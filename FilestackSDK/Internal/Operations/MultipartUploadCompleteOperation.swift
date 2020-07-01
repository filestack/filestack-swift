//
//  MultipartUploadCompleteOperation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/25/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Alamofire
import Foundation

class MultipartUploadCompleteOperation: BaseOperation {
    // MARK: - Internal Properties

    private(set) var response = NetworkJSONResponse(with: MultipartUploadError.aborted)

    // MARK: - Private Properties

    private let partsAndEtags: [Int: String]
    private let descriptor: UploadDescriptor

    // MARK: - Lifecycle

    required init(partsAndEtags: [Int: String], descriptor: UploadDescriptor) {
        self.partsAndEtags = partsAndEtags
        self.descriptor = descriptor

        super.init()

        state = .ready
    }
}

// MARK: - Overrides

extension MultipartUploadCompleteOperation {
    override func main() {
        let uploadURL = URL(string: "multipart/complete", relativeTo: UploadService.baseURL)!

        UploadService.upload(multipartFormData: multipartFormData, url: uploadURL) { response in
            self.response = response
            self.state = .finished
        }
    }
}

// MARK: - Private Functions

private extension MultipartUploadCompleteOperation {
    func multipartFormData(form: MultipartFormData) {
        form.append(descriptor.apiKey, named: "apikey")
        form.append(descriptor.uri, named: "uri")
        form.append(descriptor.region, named: "region")
        form.append(descriptor.uploadID, named: "upload_id")
        form.append(descriptor.filename, named: "filename")
        form.append(String(descriptor.filesize), named: "size")
        form.append(descriptor.mimeType, named: "mimetype")

        descriptor.options.storeOptions.append(to: form)

        if let security = descriptor.security {
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
