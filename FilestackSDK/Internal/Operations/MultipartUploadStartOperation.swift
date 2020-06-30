//
//  MultipartUploadStartOperation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/19/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Alamofire
import Foundation

class MultipartUploadStartOperation: BaseOperation {
    // MARK: - Public Properties

    var response: NetworkJSONResponse?

    // MARK: - Private Properties

    private let apiKey: String
    private let fileName: String
    private let fileSize: UInt64
    private let mimeType: String
    private let storeOptions: StorageOptions
    private let security: Security?
    private let multipart: Bool

    // MARK: - Lifecycle

    required init(apiKey: String,
                  fileName: String,
                  fileSize: UInt64,
                  mimeType: String,
                  storeOptions: StorageOptions,
                  security: Security? = nil,
                  multipart: Bool) {
        self.apiKey = apiKey
        self.fileName = fileName
        self.fileSize = fileSize
        self.mimeType = mimeType
        self.storeOptions = storeOptions
        self.security = security
        self.multipart = multipart

        super.init()
    }
}

// MARK: - Overrides

extension MultipartUploadStartOperation {
    override func main() {
        let uploadURL = URL(string: "multipart/start", relativeTo: UploadService.baseURL)!

        UploadService.upload(multipartFormData: multipartFormData, url: uploadURL) { response in
            self.response = response
            self.state = .finished
        }
    }
}

// MARK: - Private Functions

private extension MultipartUploadStartOperation {
    func multipartFormData(form: MultipartFormData) {
        form.append(apiKey, withName: "apikey")
        form.append(fileName, withName: "filename")
        form.append(mimeType, withName: "mimetype")
        form.append(String(fileSize), withName: "size")

        storeOptions.append(to: form)

        if let security = security {
            form.append(security.encodedPolicy, withName: "policy")
            form.append(security.signature, withName: "signature")
        }

        if multipart {
            form.append("true", withName: "multipart")
        }
    }
}
