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
    private let descriptor: MultipartUploadDescriptor

    // MARK: - Lifecycle

    required init(partsAndEtags: [Int: String], descriptor: MultipartUploadDescriptor) {
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
        form.append(descriptor.apiKey, withName: "apikey")
        form.append(descriptor.uri, withName: "uri")
        form.append(descriptor.region, withName: "region")
        form.append(descriptor.uploadID, withName: "upload_id")
        form.append(descriptor.filename, withName: "filename")
        form.append(String(descriptor.filesize), withName: "size")
        form.append(descriptor.mimeType, withName: "mimetype")

        descriptor.options.storeOptions.append(to: form)

        if let security = descriptor.security {
            form.append(security.encodedPolicy, withName: "policy")
            form.append(security.signature, withName: "signature")
        }

        if descriptor.useIntelligentIngestion {
            form.append("true", withName: "multipart")
        } else {
            let parts = (partsAndEtags.map { "\($0.key):\($0.value)" }).joined(separator: ";")
            form.append(parts, withName: "parts")
        }
    }
}
