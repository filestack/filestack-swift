//
//  MultipartUploadStartOperation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/19/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import Alamofire

class MultipartUploadStartOperation: BaseOperation {

    let apiKey: String
    let fileName: String
    let fileSize: UInt64
    let mimeType: String
    let storeOptions: StorageOptions
    let security: Security?
    let useIntelligentIngestionIfAvailable: Bool

    var response: NetworkJSONResponse?

    required init(apiKey: String,
                  fileName: String,
                  fileSize: UInt64,
                  mimeType: String,
                  storeOptions: StorageOptions,
                  security: Security? = nil,
                  useIntelligentIngestionIfAvailable: Bool) {
        self.apiKey = apiKey
        self.fileName = fileName
        self.fileSize = fileSize
        self.mimeType = mimeType
        self.storeOptions = storeOptions
        self.security = security
        self.useIntelligentIngestionIfAvailable = useIntelligentIngestionIfAvailable
        super.init()
    }

    override func main() {
        if isCancelled {
            state = .finished
            return
        }
        state = .executing
        uploadService.upload(multipartFormData: multipartFormData, url: uploadUrl) { response in
            self.response = response
            self.state = .finished
        }
    }
}

private extension MultipartUploadStartOperation {
    var uploadUrl: URL {
        return URL(string: "multipart/start", relativeTo: uploadService.baseURL)!
    }

    func multipartFormData(form: MultipartFormData) {
        form.append(apiKey, withName: "apikey")
        form.append(fileName, withName: "filename")
        form.append(mimeType, withName: "mimetype")
        form.append(String(fileSize), withName: "size")
        form.append(storeOptions.location.description, withName: "store_location")
        form.append(storeOptions.region, withName: "store_region")
        form.append(storeOptions.container, withName: "store_container")
        form.append(storeOptions.path, withName: "store_path")
        form.append(storeOptions.access?.description, withName: "store_access")
        if let security = security {
            form.append(security.encodedPolicy, withName: "policy")
            form.append(security.signature, withName: "signature")
        }
        if useIntelligentIngestionIfAvailable {
            form.append("true", withName: "multipart")
        }
    }
}
