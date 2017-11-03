//
//  MultipartuploadSubmitChunkOperation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 8/2/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import Alamofire


internal class MultipartUploadSubmitChunkOperation: BaseOperation {

    let partOffset: UInt64
    let dataChunk: Data
    let apiKey: String
    let part: Int
    let uri: String
    let region: String
    let uploadID: String
    let storeOptions: StorageOptions

    var response: DefaultDataResponse?
    var responseEtag: String?

    private var uploadRequest: UploadRequest?


    required init(partOffset: UInt64,
                  dataChunk: Data,
                  apiKey: String,
                  part: Int,
                  uri: String,
                  region: String,
                  uploadID: String,
                  storeOptions: StorageOptions) {

        self.partOffset = partOffset
        self.dataChunk = dataChunk
        self.apiKey = apiKey
        self.part = part
        self.uri = uri
        self.region = region
        self.uploadID = uploadID
        self.storeOptions = storeOptions

        super.init()

        isReady = true
    }

    override func main() {

        guard !isCancelled else {
            isExecuting = false
            isFinished = true
            return
        }

        isExecuting = true

        let url = URL(string: "multipart/upload", relativeTo: uploadService.baseURL)!

        let multipartFormData: (MultipartFormData) -> Void = { form in
            form.append(self.apiKey.data(using: .utf8)!, withName: "apikey")
            form.append(String(self.part).data(using: .utf8)!, withName: "part")
            form.append(String(self.dataChunk.count).data(using: .utf8)!, withName: "size")
            form.append(self.dataChunk.base64MD5Digest().data(using: .utf8)!, withName: "md5")
            form.append(self.uri.data(using: .utf8)!, withName: "uri")
            form.append(self.region.data(using: .utf8)!, withName: "region")
            form.append(self.uploadID.data(using: .utf8)!, withName: "upload_id")
            form.append("true".data(using: .utf8)!, withName: "multipart")
            form.append(String(self.partOffset).data(using: .utf8)!, withName: "offset")
        }

        uploadService.upload(multipartFormData: multipartFormData, url: url) { response in
            guard !self.isCancelled && !self.isFinished else { return }

            guard let urlString = response.json?["url"] as? String, let url = URL(string: urlString) else {
                self.isExecuting = false
                self.isFinished = true

                return
            }

            guard let headers = response.json?["headers"] as? [String: String] else {
                self.isExecuting = false
                self.isFinished = true

                return
            }

            self.uploadRequest = uploadService.upload(data: self.dataChunk,
                                                      to: url,
                                                      method: .put,
                                                      headers: headers)

            self.uploadRequest?.response { (response) in
                self.response = response
                self.responseEtag = response.response?.allHeaderFields["Etag"] as? String
                self.isExecuting = false
                self.isFinished = true
            }
        }
    }

    override func cancel() {

        super.cancel()
        uploadRequest?.cancel()
        isExecuting = false
        isFinished = true
    }
}
