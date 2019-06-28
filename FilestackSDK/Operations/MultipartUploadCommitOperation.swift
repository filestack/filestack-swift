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
    let apiKey: String
    let fileSize: UInt64
    let part: Int
    let uri: String
    let region: String
    let uploadID: String
    let storeOptions: StorageOptions

    var response: NetworkJSONResponse?

    required init(apiKey: String,
                  fileSize: UInt64,
                  part: Int,
                  uri: String,
                  region: String,
                  uploadID: String,
                  storeOptions: StorageOptions) {
        self.apiKey = apiKey
        self.fileSize = fileSize
        self.part = part
        self.uri = uri
        self.region = region
        self.uploadID = uploadID
        self.storeOptions = storeOptions

        super.init()

        state = .ready
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

private extension MultipartUploadCommitOperation {
    var uploadUrl: URL {
        return URL(string: "multipart/commit", relativeTo: uploadService.baseURL)!
    }

    func multipartFormData(form: MultipartFormData) {
        form.append(apiKey, withName: "apikey")
        form.append(uri, withName: "uri")
        form.append(region, withName: "region")
        form.append(uploadID, withName: "upload_id")
        form.append(String(fileSize), withName: "size")
        form.append(String(part), withName: "part")
        form.append(storeOptions.location.description, withName: "store_location")
    }
}
