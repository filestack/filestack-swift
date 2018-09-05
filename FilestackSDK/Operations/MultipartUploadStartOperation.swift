//
//  MultipartUploadStartOperation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/19/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import Alamofire

class MultipartUploadStartOperation: BaseOperation {

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
  }
  
  override func main() {
    if isCancelled {
      state = .finished
      return
    }
    state = .executing
    uploadService.upload(multipartFormData: multipartFormData, url: uploadUrl) { response in
      self.response = response
      self.state = .finished
    }
  }
}

private extension MultipartUploadStartOperation {
  var uploadUrl: URL {
    return URL(string: "multipart/start", relativeTo: uploadService.baseURL)!
  }
  
  func multipartFormData(form: MultipartFormData) {
    form.append(apiKey.data(using: .utf8)!, withName: "apikey")
    form.append(fileName.data(using: .utf8)!, withName: "filename")
    form.append(mimeType.data(using: .utf8)!, withName: "mimetype")
    form.append(String(fileSize).data(using: .utf8)!, withName: "size")
    if let storeLocation = storeOptions.location.description.data(using: .utf8) {
      form.append(storeLocation, withName: "store_location")
    }
    if let storeRegionData = storeOptions.region?.data(using: .utf8) {
      form.append(storeRegionData, withName: "store_region")
    }
    if let storeContainerData = storeOptions.container?.data(using: .utf8) {
      form.append(storeContainerData, withName: "store_container")
    }
    if let storePathData = storeOptions.path?.data(using: .utf8) {
      form.append(storePathData, withName: "store_path")
    }
    if let storeAccessData = storeOptions.access?.description.data(using: .utf8) {
      form.append(storeAccessData, withName: "store_access")
    }
    if let security = security {
      form.append(security.encodedPolicy.data(using: .utf8)!, withName: "policy")
      form.append(security.signature.data(using: .utf8)!, withName: "signature")
    }
    if useIntelligentIngestionIfAvailable {
      form.append("true".data(using: .utf8)!, withName: "multipart")
    }
  }
}
