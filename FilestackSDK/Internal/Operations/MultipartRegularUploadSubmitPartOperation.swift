//
//  MultipartRegularUploadSubmitPartOperation.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 26/09/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Alamofire
import Foundation

internal class MultipartRegularUploadSubmitPartOperation: BaseOperation, MultipartUploadSubmitPartProtocol {
    typealias MultiPartFormDataClosure = (MultipartFormData) -> Void

    let seek: UInt64
    let reader: UploadableReader
    let fileName: String
    let fileSize: UInt64
    let apiKey: String
    let part: Int
    let uri: String
    let region: String
    let uploadID: String
    let storeOptions: StorageOptions
    let chunkSize: Int
    var uploadProgress: ((Int64) -> Void)?

    var response: DefaultDataResponse?
    var responseEtag: String?
    var didFail: Bool

    private var beforeCommitCheckPointOperation: BlockOperation?

    required init(seek: UInt64,
                  reader: UploadableReader,
                  fileName: String,
                  fileSize: UInt64,
                  apiKey: String,
                  part: Int,
                  uri: String,
                  region: String,
                  uploadID: String,
                  storeOptions: StorageOptions,
                  chunkSize: Int,
                  uploadProgress: @escaping ((Int64) -> Void)) {
        self.seek = seek
        self.reader = reader
        self.fileName = fileName
        self.fileSize = fileSize
        self.apiKey = apiKey
        self.part = part
        self.uri = uri
        self.region = region
        self.uploadID = uploadID
        self.storeOptions = storeOptions
        self.chunkSize = chunkSize
        self.didFail = false
        self.uploadProgress = uploadProgress

        super.init()

        state = .ready
    }

    override func main() {
        upload()
    }

    override func cancel() {
        super.cancel()
        didFail = true
    }
}

private extension MultipartRegularUploadSubmitPartOperation {
    func upload() {
        guard !isCancelled else {
            state = .finished
            return
        }

        state = .executing

        reader.seek(position: seek)
        let dataChunk = reader.read(amount: chunkSize)

        let url = URL(string: "multipart/upload", relativeTo: UploadService.baseURL)!

        UploadService.upload(multipartFormData: multipartFormData(dataChunk: dataChunk),
                             url: url,
                             completionHandler: uploadResponseHandler(dataChunk: dataChunk))
    }

    func multipartFormData(dataChunk: Data) -> MultiPartFormDataClosure {
        return { form in
            form.append(self.apiKey, withName: "apikey")
            form.append(self.uri, withName: "uri")
            form.append(self.region, withName: "region")
            form.append(self.uploadID, withName: "upload_id")
            form.append(String(dataChunk.count), withName: "size")
            form.append(String(self.part), withName: "part")
            form.append(dataChunk.base64MD5Digest(), withName: "md5")

            self.storeOptions.append(to: form)
        }
    }

    func uploadResponseHandler(dataChunk: Data) -> ((NetworkJSONResponse) -> Void) {
        return { response in
            guard let uploadRequest = self.uploadRequest(with: response.json, dataChunk: dataChunk) else {
                self.state = .finished
                return
            }
            uploadRequest.response { response in
                let chunkSize = Int64(dataChunk.count)
                self.response = response
                self.responseEtag = response.response?.allHeaderFields["Etag"] as? String
                self.state = .finished
                self.uploadProgress?(chunkSize)
                self.uploadProgress = nil
            }
        }
    }

    func uploadRequest(with json: [String: Any]?, dataChunk: Data) -> UploadRequest? {
        guard let url = url(from: json), let headers = json?["headers"] as? [String: String] else { return nil }
        return UploadService.upload(data: dataChunk, to: url, method: .put, headers: headers)
    }

    func url(from json: [String: Any]?) -> URL? {
        let urlString = json?["url"] as? String ?? ""
        return URL(string: urlString)
    }
}
