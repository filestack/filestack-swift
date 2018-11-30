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
  let storeOptions: StorageOptions
  let parts: String
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
    self.parts = (partsAndEtags.map { "\($0.key):\($0.value)" }).joined(separator:";")
    self.useIntelligentIngestion = useIntelligentIngestion
    
    super.init()
    
    self.state = .ready
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

private extension MultipartUploadCompleteOperation {
  var uploadUrl: URL {
    return URL(string: "multipart/complete", relativeTo: uploadService.baseURL)!
  }
  
  func multipartFormData(form: MultipartFormData) {
    form.append(apiKey, withName: "apikey")
    form.append(uri, withName: "uri")
    form.append(region, withName: "region")
    form.append(uploadID, withName: "upload_id")
    form.append(fileName, withName: "filename")
    form.append(String(fileSize), withName: "size")
    form.append(mimeType, withName: "mimetype")
    form.append(storeOptions.location.description, withName: "store_location")
    form.append(storeOptions.region, withName: "store_region")
    form.append(storeOptions.container, withName: "store_container")
    form.append(storeOptions.path, withName: "store_path")
    form.append(storeOptions.access?.description, withName: "store_access")
    if self.useIntelligentIngestion {
      form.append("true", withName: "multipart")
    } else {
      form.append(parts, withName: "parts")
    }
  }
}
