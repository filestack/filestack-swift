//
//  MultipartUploadCommitOperation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/31/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Alamofire
import Foundation

class MultipartUploadCommitOperation: BaseOperation {
    // MARK: - Internal Properties

    private(set) var response: NetworkJSONResponse?

    // MARK: - Private Properties

    private let part: Int
    private let descriptor: UploadDescriptor

    // MARK: - Lifecyle

    required init(descriptor: UploadDescriptor, part: Int) {
        self.descriptor = descriptor
        self.part = part

        super.init()

        state = .ready
    }
}

// MARK: - Overrides

extension MultipartUploadCommitOperation {
    override func main() {
        let uploadURL = URL(string: "multipart/commit", relativeTo: UploadService.baseURL)!

        UploadService.upload(multipartFormData: multipartFormData, url: uploadURL) { response in
            self.response = response
            self.state = .finished
        }
    }
}

// MARK: - Private Functions

private extension MultipartUploadCommitOperation {
    func multipartFormData(form: MultipartFormData) {
        form.append(descriptor.apiKey, named: "apikey")
        form.append(descriptor.uri, named: "uri")
        form.append(descriptor.region, named: "region")
        form.append(descriptor.uploadID, named: "upload_id")
        form.append(String(descriptor.filesize), named: "size")
        form.append(String(part), named: "part")
        form.append(descriptor.options.storeOptions.location.description, named: "store_location")
    }
}
