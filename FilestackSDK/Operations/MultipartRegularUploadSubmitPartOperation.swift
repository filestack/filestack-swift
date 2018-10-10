//
//  MultipartRegularUploadSubmitPartOperation.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 26/09/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation
import Alamofire

internal class MultipartRegularUploadSubmitPartOperation: BaseOperation, MultipartUploadSubmitPartProtocol {
  typealias MultiPartFormDataClosure = (MultipartFormData) -> Void
  
  let seek: UInt64
  let localURL: URL
  let fileName: String
  let fileSize: UInt64
  let apiKey: String
  let part: Int
  let uri: String
  let region: String
  let uploadID: String
  let chunkSize: Int
  var uploadProgress: ((Int64) -> Void)?
  
  var response: DefaultDataResponse?
  var responseEtag: String?
  var didFail: Bool
  
  private var fileHandle: FileHandle?
  
  private var beforeCommitCheckPointOperation: BlockOperation?
  
  required init(seek: UInt64,
                localURL: URL,
                fileName: String,
                fileSize: UInt64,
                apiKey: String,
                part: Int,
                uri: String,
                region: String,
                uploadID: String,
                chunkSize: Int,
                uploadProgress: @escaping ((Int64) -> Void)) {
    self.seek = seek
    self.localURL = localURL
    self.fileName = fileName
    self.fileSize = fileSize
    self.apiKey = apiKey
    self.part = part
    self.uri = uri
    self.region = region
    self.uploadID = uploadID
    self.chunkSize = chunkSize
    self.didFail = false
    self.uploadProgress = uploadProgress
    super.init()
    
    self.state = .ready
  }
  
  override func main() {
    guard let handle = try? FileHandle(forReadingFrom: localURL) else {
      self.state = .finished
      return
    }
    fileHandle = handle
    upload()
  }
  
  override func cancel() {
    super.cancel()
    didFail = true
  }
}

private extension MultipartRegularUploadSubmitPartOperation {
  func upload() {
    guard !isCancelled, let fileHandle = fileHandle else {
      self.state = .finished
      return
    }
    
    state = .executing
    
    fileHandle.seek(toFileOffset: self.seek)
    
    let dataChunk = fileHandle.readData(ofLength: chunkSize)
    
    fileHandle.closeFile()
    
    let url = URL(string: "multipart/upload", relativeTo: uploadService.baseURL)!
    
    uploadService.upload(multipartFormData: multipartFormData(dataChunk: dataChunk),
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
    return uploadService.upload(data: dataChunk, to: url, method: .put, headers: headers)
  }
  
  func url(from json: [String: Any]?) -> URL? {
    let urlString = json?["url"] as? String ?? ""
    return URL(string: urlString)
  }
}
