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
    let storeOptions: StorageOptions
    let useIntelligentIngestion: Bool

    var response = NetworkJSONResponse(with: MultipartUploadError.aborted)


    required init(apiKey: String,
                  fileName: String,
                  fileSize: UInt64,
                  mimeType: String,
                  uri: String,
                  region: String,
                  uploadID: String,
                  storeOptions: StorageOptions,
                  partsAndEtags: [Int: String],
                  useIntelligentIngestion: Bool) {
        self.apiKey = apiKey
        self.fileName = fileName
        self.fileSize = fileSize
        self.mimeType = mimeType
        self.uri = uri
        self.region = region
        self.uploadID = uploadID
        self.storeOptions = storeOptions
        self.parts = (partsAndEtags.map { "\($0.key):\($0.value)" }).joined(separator: ";")
        self.useIntelligentIngestion = useIntelligentIngestion

        super.init()

        self.isReady = true
    }

    override func main() {

        guard !isCancelled else {
            isExecuting = false
            isFinished = true
            return
        }

        isExecuting = true

        let url = URL(string: "multipart/complete", relativeTo: uploadService.baseURL)!

        let multipartFormData: (MultipartFormData) -> Void = { form in
            form.append(self.apiKey.data(using: .utf8)!, withName: "apikey")
            form.append(self.uri.data(using: .utf8)!, withName: "uri")
            form.append(self.region.data(using: .utf8)!, withName: "region")
            form.append(self.uploadID.data(using: .utf8)!, withName: "upload_id")
            form.append(self.fileName.data(using: .utf8)!, withName: "filename")
            form.append(String(self.fileSize).data(using: .utf8)!, withName: "size")
            form.append(self.mimeType.data(using: .utf8)!, withName: "mimetype")
            if let storeLocation = self.storeOptions.location.description.data(using: .utf8) {
                form.append(storeLocation, withName: "store_location")
            }
            if let storeRegionData = self.storeOptions.region?.data(using: .utf8) {
                form.append(storeRegionData, withName: "store_region")
            }
            if let storeContainerData = self.storeOptions.container?.data(using: .utf8) {
                form.append(storeContainerData, withName: "store_container")
            }
            if let storePathData = self.storeOptions.path?.data(using: .utf8) {
                form.append(storePathData, withName: "store_path")
            }
            if let storeAccessData = self.storeOptions.access?.description.data(using: .utf8) {
                form.append(storeAccessData, withName: "store_access")
            }
            if self.useIntelligentIngestion {
                form.append("true".data(using: .utf8)!, withName: "multipart")
            } else {
                form.append(self.parts.data(using: .utf8)!, withName: "parts")
            }
        }

        uploadService.upload(multipartFormData: multipartFormData, url: url) { response in
            self.response = response
            self.isExecuting = false
            self.isFinished = true
        }
    }
}
