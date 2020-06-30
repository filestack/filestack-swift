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
    let offset: UInt64
    let chunk: Data
    let part: Int
    let descriptor: MultipartUploadDescriptor
    let progress: Progress

    var receivedResponse: MultipartResponse?

    private var uploadRequest: UploadRequest?

    required init(offset: UInt64,
                  chunk: Data,
                  part: Int,
                  descriptor: MultipartUploadDescriptor) {
        self.offset = offset
        self.chunk = chunk
        self.part = part
        self.progress = MirroredProgress()
        self.progress.totalUnitCount = Int64(chunk.count)
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

        uploadRequest = UploadService.upload(data: chunk, to: url, method: .put, headers: headers)

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
        form.append(descriptor.apiKey, withName: "apikey")
        form.append(String(part), withName: "part")
        form.append(String(chunk.count), withName: "size")
        form.append(chunk.base64MD5Digest(), withName: "md5")
        form.append(descriptor.uri, withName: "uri")
        form.append(descriptor.region, withName: "region")
        form.append(descriptor.uploadID, withName: "upload_id")
        form.append("true", withName: "multipart")
        form.append(String(offset), withName: "offset")
    }
}
