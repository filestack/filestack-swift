//
//  MultipartUploadCompleteOperation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/25/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import Alamofire


internal class MultipartUploadCompleteOperation: BaseOperation {

    let apiKey: String
    let fileName: String
    let fileSize: UInt64
    let mimeType: String
    let uri: String
    let region: String
    let uploadID: String
    let parts: String
    let storeLocation: StorageLocation

    var response: NetworkJSONResponse?


    required init(apiKey: String,
                  fileName: String,
                  fileSize: UInt64,
                  mimeType: String,
                  uri: String,
                  region: String,
                  uploadID: String,
                  storeLocation: StorageLocation,
                  partsAndEtags: [Int: String]) {

        self.apiKey = apiKey
        self.fileName = fileName
        self.fileSize = fileSize
        self.mimeType = mimeType
        self.uri = uri
        self.region = region
        self.uploadID = uploadID
        self.storeLocation = storeLocation
        self.parts = (partsAndEtags.map { "\($0.key):\($0.value)" }).joined(separator: ";")

        super.init()

        self.isReady = true
    }

    override func main() {

        guard !isCancelled else {
            isFinished = true
            return
        }

        isExecuting = true

        let url = URL(string: "multipart/complete", relativeTo: uploadService.baseURL)!

        let multipartFormData: (MultipartFormData) -> Void = { form in

            let apiKeyData = self.apiKey.data(using: .utf8)!
            let uriData = self.uri.data(using: .utf8)!
            let regionData = self.region.data(using: .utf8)!
            let uploadIDData = self.uploadID.data(using: .utf8)!
            let fileNameData = self.fileName.data(using: .utf8)!
            let fileSizeData = "\(self.fileSize)".data(using: .utf8)!
            let mimeTypeData = self.mimeType.data(using: .utf8)!
            let partsData = self.parts.data(using: .utf8)!
            let storeLocationData = String(describing: self.storeLocation).data(using: .utf8)!

            form.append(apiKeyData, withName: "apikey")
            form.append(uriData, withName: "uri")
            form.append(regionData, withName: "region")
            form.append(uploadIDData, withName: "upload_id")
            form.append(fileNameData, withName: "filename")
            form.append(fileSizeData, withName: "size")
            form.append(mimeTypeData, withName: "mimetype")
            form.append(partsData, withName: "parts")
            form.append(storeLocationData, withName: "store_location")
        }

        uploadService.upload(multipartFormData: multipartFormData,
                             url: url) { response in

            self.response = response
            self.isFinished = true
        }
    }
}
