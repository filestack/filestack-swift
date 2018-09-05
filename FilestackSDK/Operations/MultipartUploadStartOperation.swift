//
//  MultipartUploadStartOperation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/19/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import Alamofire


internal class MultipartUploadStartOperation: BaseOperation {

    let apiKey: String
    let fileName: String
    let fileSize: UInt64
    let mimeType: String
    let storeOptions: StorageOptions
    let security: Security?
    let useIntelligentIngestionIfAvailable: Bool

    var response: NetworkJSONResponse?


    required init(apiKey: String,
                  fileName: String,
                  fileSize: UInt64,
                  mimeType: String,
                  storeOptions: StorageOptions,
                  security: Security? = nil,
                  useIntelligentIngestionIfAvailable: Bool) {

        self.apiKey = apiKey
        self.fileName = fileName
        self.fileSize = fileSize
        self.mimeType = mimeType
        self.storeOptions = storeOptions
        self.security = security
        self.useIntelligentIngestionIfAvailable = useIntelligentIngestionIfAvailable

        super.init()

        self.state = .ready
    }

    override func main() {

        guard !isCancelled else {
            self.state = .finished
            return
        }
      
        state = .executing

        let url = URL(string: "multipart/start", relativeTo: uploadService.baseURL)!

        let multipartFormData: (MultipartFormData) -> Void = { form in
            form.append(self.apiKey.data(using: .utf8)!, withName: "apikey")
            form.append(self.fileName.data(using: .utf8)!, withName: "filename")
            form.append(self.mimeType.data(using: .utf8)!, withName: "mimetype")
            form.append(String(self.fileSize).data(using: .utf8)!, withName: "size")

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

            if let security = self.security {

                let policyData = security.encodedPolicy.data(using: .utf8)!
                let signatureData = security.signature.data(using: .utf8)!

                form.append(policyData, withName: "policy")
                form.append(signatureData, withName: "signature")
            }

            if self.useIntelligentIngestionIfAvailable {
                // Attempt to use Intelligent Ingestion
                form.append("true".data(using: .utf8)!, withName: "multipart")
            }
        }

        uploadService.upload(multipartFormData: multipartFormData, url: url) { response in
            self.response = response
            self.state = .finished
        }
    }
}
