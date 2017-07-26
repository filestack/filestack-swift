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
    let storeLocation: StorageLocation
    let security: Security?

    var response: NetworkJSONResponse?


    required init(apiKey: String,
                  fileName: String,
                  fileSize: UInt64,
                  mimeType: String,
                  storeLocation: StorageLocation,
                  security: Security? = nil) {

        self.apiKey = apiKey
        self.fileName = fileName
        self.fileSize = fileSize
        self.mimeType = mimeType
        self.storeLocation = storeLocation
        self.security = security

        super.init()

        self.isReady = true
    }

    override func main() {

        guard !isCancelled else {
            isFinished = true
            return
        }

        isExecuting = true

        let url = URL(string: "multipart/start", relativeTo: uploadService.baseURL)!

        let multipartFormData: (MultipartFormData) -> Void = { form in

            let apiKeyData = self.apiKey.data(using: .utf8)!
            let fileNameData = self.fileName.data(using: .utf8)!
            let fileSizeData = "\(self.fileSize)".data(using: .utf8)!
            let mimeTypeData = self.mimeType.data(using: .utf8)!
            let storeLocationData = String(describing: self.storeLocation).data(using: .utf8)!

            form.append(apiKeyData, withName: "apikey")
            form.append(fileNameData, withName: "filename")
            form.append(mimeTypeData, withName: "mimetype")
            form.append(fileSizeData, withName: "size")
            form.append(storeLocationData, withName: "store_location")

            if let security = self.security {

                let policyData = security.encodedPolicy.data(using: .utf8)!
                let signatureData = security.signature.data(using: .utf8)!

                form.append(policyData, withName: "policy")
                form.append(signatureData, withName: "signature")
            }
        }

        uploadService.upload(multipartFormData: multipartFormData, url: url) { response in

            self.response = response
            self.isFinished = true
        }
    }
}
