//
//  MultipartuploadSubmitChunkOperation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 8/2/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Alamofire
import Foundation

class MultipartUploadSubmitChunkOperation: BaseOperation {
    let partOffset: UInt64
    let dataChunk: Data
    let apiKey: String
    let part: Int
    let uri: String
    let region: String
    let uploadID: String
    let storeOptions: StorageOptions

    var receivedResponse: MultipartResponse?

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
    }

    override func main() {
        if isCancelled {
            state = .finished
            return
        }
        state = .executing
        UploadService.upload(multipartFormData: multipartFormData, url: uploadUrl, completionHandler: uploadDidFinish)
    }

    override func cancel() {
        super.cancel()
        uploadRequest?.cancel()
        state = .finished
    }
}

private extension MultipartUploadSubmitChunkOperation {
    func uploadDidFinish(with response: NetworkJSONResponse) {
        guard
            !isCancelled,
            !isFinished,
            let urlString = response.json?["url"] as? String,
            let url = URL(string: urlString),
            let headers = response.json?["headers"] as? [String: String] else {
            return
        }

        uploadRequest = UploadService.upload(data: dataChunk, to: url, method: .put, headers: headers)

        uploadRequest?.response { response in
            self.saveResponse(response)
            self.state = .finished
        }
    }

    func saveResponse(_ response: DefaultDataResponse) {
        receivedResponse = MultipartResponse(response: response.response,
                                             error: response.error,
                                             etag: response.response?.allHeaderFields["Etag"] as? String)
    }

    var uploadUrl: URL {
        return URL(string: "multipart/upload", relativeTo: UploadService.baseURL)!
    }

    func multipartFormData(form: MultipartFormData) {
        form.append(apiKey, withName: "apikey")
        form.append(String(part), withName: "part")
        form.append(String(dataChunk.count), withName: "size")
        form.append(dataChunk.base64MD5Digest(), withName: "md5")
        form.append(uri, withName: "uri")
        form.append(region, withName: "region")
        form.append(uploadID, withName: "upload_id")
        form.append("true", withName: "multipart")
        form.append(String(partOffset), withName: "offset")
    }
}
