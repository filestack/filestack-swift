//
//  MultipartRegularUploadSubmitPartOperation.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 26/09/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Alamofire
import Foundation

class MultipartRegularUploadSubmitPartOperation: BaseOperation, MultipartUploadSubmitPartProtocol {
    // MARK: - Public Properties

    let part: Int
    var response: DefaultDataResponse?
    var responseEtag: String?
    var didFail: Bool = false

    private(set) lazy var progress: Progress = {
        let progress = MirroredProgress()

        progress.totalUnitCount = Int64(partSize)

        return progress
    }()

    // MARK: - Private Properties

    private let offset: UInt64
    private let partSize: Int
    private let descriptor: UploadDescriptor
    private var beforeCommitCheckPointOperation: BlockOperation?

    // MARK: - Lifecycle

    required init(offset: UInt64,
                  part: Int,
                  partSize: Int,
                  descriptor: UploadDescriptor) {
        self.offset = offset
        self.part = part
        self.partSize = partSize
        self.descriptor = descriptor

        super.init()

        state = .ready
    }
}

// MARK: - Operation Overrides

extension MultipartRegularUploadSubmitPartOperation {
    override func main() {
        upload()
    }

    override func cancel() {
        super.cancel()
        didFail = true
    }
}

// MARK: - Private Functions

private extension MultipartRegularUploadSubmitPartOperation {
    typealias MultiPartFormDataClosure = (MultipartFormData) -> Void

    func upload() {
        descriptor.reader.seek(position: offset)

        let dataChunk = descriptor.reader.read(amount: partSize)
        let url = URL(string: "multipart/upload", relativeTo: UploadService.baseURL)!

        UploadService.upload(multipartFormData: multipartFormData(dataChunk: dataChunk),
                             url: url,
                             completionHandler: uploadResponseHandler(dataChunk: dataChunk))
    }

    func multipartFormData(dataChunk: Data) -> MultiPartFormDataClosure {
        return { form in
            form.append(self.descriptor.apiKey, named: "apikey")
            form.append(self.descriptor.uri, named: "uri")
            form.append(self.descriptor.region, named: "region")
            form.append(self.descriptor.uploadID, named: "upload_id")
            form.append(String(dataChunk.count), named: "size")
            form.append(String(self.part), named: "part")
            form.append(dataChunk.base64MD5Digest(), named: "md5")

            self.descriptor.options.storeOptions.append(to: form)
        }
    }

    func uploadResponseHandler(dataChunk: Data) -> ((NetworkJSONResponse) -> Void) {
        return { response in
            guard let uploadRequest = self.uploadRequest(with: response.json, dataChunk: dataChunk) else {
                self.state = .finished
                return
            }

            uploadRequest.response { response in
                self.response = response
                self.responseEtag = response.response?.allHeaderFields["Etag"] as? String
                self.state = .finished
            }
        }
    }

    func uploadRequest(with json: [String: Any]?, dataChunk: Data) -> UploadRequest? {
        guard let url = url(from: json), let headers = json?["headers"] as? [String: String] else { return nil }
        guard let request = UploadService.upload(data: dataChunk, to: url, method: .put, headers: headers) else { return nil }

        request.uploadProgress { progress in
            self.progress.totalUnitCount = progress.totalUnitCount
            self.progress.completedUnitCount = progress.completedUnitCount
        }

        return request
    }

    func url(from json: [String: Any]?) -> URL? {
        let urlString = json?["url"] as? String ?? ""
        return URL(string: urlString)
    }
}
