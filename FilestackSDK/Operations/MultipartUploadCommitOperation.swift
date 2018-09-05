//
//  MultipartUploadCommitOperation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/31/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import Alamofire


internal class MultipartUploadCommitOperation: BaseOperation {

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

        self.state = .ready
    }

    override func main() {

        guard !isCancelled else {
            self.state = .finished
            return
        }

        self.state = .executing

        let url = URL(string: "multipart/commit", relativeTo: uploadService.baseURL)!

        let multipartFormData: (MultipartFormData) -> Void = { form in

            form.append(self.apiKey.data(using: .utf8)!, withName: "apikey")
            form.append(self.uri.data(using: .utf8)!, withName: "uri")
            form.append(self.region.data(using: .utf8)!, withName: "region")
            form.append(self.uploadID.data(using: .utf8)!, withName: "upload_id")
            form.append(String(self.fileSize).data(using: .utf8)!, withName: "size")
            form.append(String(self.part).data(using: .utf8)!, withName: "part")
            form.append(self.storeOptions.location.description.data(using: .utf8)!, withName: "store_location")
        }

        uploadService.upload(multipartFormData: multipartFormData, url: url) { response in
            self.response = response
            self.state = .finished
        }
    }
}
