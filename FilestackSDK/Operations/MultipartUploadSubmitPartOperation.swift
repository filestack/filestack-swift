//
//  MultipartUploadSubmitPartOperation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/20/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import Alamofire


internal class MultipartUploadSubmitPartOperation: BaseOperation {

    let seek: UInt64
    let localURL: URL
    let fileName: String
    let apiKey: String
    let part: Int
    let uri: String
    let region: String
    let uploadID: String
    let storageLocation: StorageLocation

    var responseEtag: String?


    required init(seek: UInt64,
                  localURL: URL,
                  fileName: String,
                  apiKey: String,
                  part: Int,
                  uri: String,
                  region: String,
                  uploadID: String,
                  storageLocation: StorageLocation) {

        self.seek = seek
        self.localURL = localURL
        self.fileName = fileName
        self.apiKey = apiKey
        self.part = part
        self.uri = uri
        self.region = region
        self.uploadID = uploadID
        self.storageLocation = storageLocation

        super.init()

        self.isReady = true
    }

    override func main() {

        guard !isCancelled else {
            isFinished = true
            return
        }

        isExecuting = true

        let url = URL(string: "multipart/upload", relativeTo: uploadService.baseURL)!

        guard let fh = try? FileHandle(forReadingFrom: self.localURL) else {
            self.isFinished = true
            return
        }

        fh.seek(toFileOffset: self.seek)
        let dataChunk = fh.readData(ofLength: Config.defaultChunkSize)

        fh.closeFile()

        let multipartFormData: (MultipartFormData) -> Void = { form in

            form.append(self.apiKey.data(using: .utf8)!, withName: "apikey")
            form.append("\(self.part)".data(using: .utf8)!, withName: "part")
            form.append("\(dataChunk.count)".data(using: .utf8)!, withName: "size")
            form.append(dataChunk.base64MD5Digest().data(using: .utf8)!, withName: "md5")
            form.append(self.uri.data(using: .utf8)!, withName: "uri")
            form.append(self.region.data(using: .utf8)!, withName: "region")
            form.append(self.uploadID.data(using: .utf8)!, withName: "upload_id")
            form.append(String(describing: self.storageLocation).data(using: .utf8)!, withName: "store_location")
        }

        uploadService.upload(multipartFormData: multipartFormData, url: url) { response in

            guard let urlString = response.json?["url"] as? String, let url = URL(string: urlString) else {
                self.isFinished = true
                return
            }

            guard let headers = response.json?["headers"] as? [String: String] else {
                self.isFinished = true
                return
            }

            let uploadRequest = uploadService.upload(data: dataChunk, to: url, method: .put, headers: headers)

            uploadRequest.response(completionHandler: { (response) in

                self.responseEtag = response.response?.allHeaderFields["Etag"] as? String
                self.isFinished = true
            })
        }
    }
}
