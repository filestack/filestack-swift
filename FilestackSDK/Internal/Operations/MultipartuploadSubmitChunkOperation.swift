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
    let data: Data
    let offset: UInt64
    let part: Int
    let descriptor: UploadDescriptor
    let progress: Progress

    var receivedResponse: MultipartResponse?

    private var uploadRequest: UploadRequest?

    required init(data: Data, offset: UInt64, part: Int, descriptor: UploadDescriptor) {
        self.data = data
        self.offset = offset
        self.part = part
        self.progress = MirroredProgress()
        self.progress.totalUnitCount = Int64(data.count)
        self.descriptor = descriptor

        super.init()
    }

    override func main() {
        UploadService.upload(multipartFormData: multipartFormData, url: uploadURL, completionHandler: uploadDidFinish)
    }

    override func cancel() {
        super.cancel()
        uploadRequest?.cancel()
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

        uploadRequest = UploadService.upload(data: data, to: url, method: .put, headers: headers)

        uploadRequest?.uploadProgress(closure: { progress in
            self.progress.totalUnitCount = progress.totalUnitCount
            self.progress.completedUnitCount = progress.completedUnitCount
        })

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

    var uploadURL: URL {
        return URL(string: "multipart/upload", relativeTo: UploadService.baseURL)!
    }

    func multipartFormData(form: MultipartFormData) {
        form.append(descriptor.apiKey, named: "apikey")
        form.append(String(part), named: "part")
        form.append(String(data.count), named: "size")
        form.append(data.base64MD5Digest(), named: "md5")
        form.append(descriptor.uri, named: "uri")
        form.append(descriptor.region, named: "region")
        form.append(descriptor.uploadID, named: "upload_id")
        form.append("true", named: "multipart")
        form.append(String(offset), named: "offset")
    }
}
