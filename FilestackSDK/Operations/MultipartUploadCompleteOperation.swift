//
//  MultipartUploadCompleteOperation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/25/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import Alamofire

class MultipartUploadCompleteOperation: BaseOperation {
  
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
    
    self.state = .ready
  }
  
  override func main() {
    guard !isCancelled else {
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

private extension MultipartUploadCompleteOperation {
  var uploadUrl: URL {
    return URL(string: "multipart/complete", relativeTo: uploadService.baseURL)!
  }
  
  func multipartFormData(form: MultipartFormData) {
    form.append(apiKey.data(using: .utf8)!, withName: "apikey")
    form.append(uri.data(using: .utf8)!, withName: "uri")
    form.append(region.data(using: .utf8)!, withName: "region")
    form.append(uploadID.data(using: .utf8)!, withName: "upload_id")
    form.append(fileName.data(using: .utf8)!, withName: "filename")
    form.append(String(fileSize).data(using: .utf8)!, withName: "size")
    form.append(mimeType.data(using: .utf8)!, withName: "mimetype")
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
    if self.useIntelligentIngestion {
      form.append("true".data(using: .utf8)!, withName: "multipart")
    } else {
      form.append(parts.data(using: .utf8)!, withName: "parts")
    }
  }

}
