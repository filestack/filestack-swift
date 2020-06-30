//
//  MultipartUploadCommitOperation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/31/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Alamofire
import Foundation

struct MultipartUploadDescriptor {
    let apiKey: String
    let security: Security?
    let options: UploadOptions
    let reader: UploadableReader
    let filename: String
    let filesize: UInt64
    let mimeType: String
    let uri: String
    let region: String
    let uploadID: String
    let useIntelligentIngestion: Bool
}

class MultipartUploadCommitOperation: BaseOperation {
    let part: Int
    let descriptor: MultipartUploadDescriptor
    private(set) var response: NetworkJSONResponse?

    required init(descriptor: MultipartUploadDescriptor, part: Int) {
        self.descriptor = descriptor
        self.part = part

        super.init()

        state = .ready
    }

    override func main() {
        UploadService.upload(multipartFormData: multipartFormData, url: uploadURL) { response in
            self.response = response
            self.state = .finished
        }
    }
}

private extension MultipartUploadCommitOperation {
    var uploadURL: URL {
        return URL(string: "multipart/commit", relativeTo: UploadService.baseURL)!
    }

    func multipartFormData(form: MultipartFormData) {
        form.append(descriptor.apiKey, withName: "apikey")
        form.append(descriptor.uri, withName: "uri")
        form.append(descriptor.region, withName: "region")
        form.append(descriptor.uploadID, withName: "upload_id")
        form.append(String(descriptor.filesize), withName: "size")
        form.append(String(part), withName: "part")
        form.append(descriptor.options.storeOptions.location.description, withName: "store_location")
    }
}
