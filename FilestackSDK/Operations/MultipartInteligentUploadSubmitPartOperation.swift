//
//  MultipartInteligentUploadSubmitPartOperation.swift
//  FilestackSDK
//
//  Created by Mihály Papp on 26/09/2018.
//  Copyright © 2018 Filestack. All rights reserved.
//

import Foundation
import Alamofire

internal class MultipartInteligentUploadSubmitPartOperation: BaseOperation, MultipartUploadSubmitPartProtocol {

  let resumableMobileChunkSize = 1 * Int(pow(Double(1024), Double(2)))
  let resumableDesktopChunkSize = 8 * Int(pow(Double(1024), Double(2)))
  let minimumPartChunkSize = 32768
  
  let seek: UInt64
  let localURL: URL
  let fileName: String
  let fileSize: UInt64
  let apiKey: String
  let part: Int
  let uri: String
  let region: String
  let uploadID: String
  let storeOptions: StorageOptions
  let chunkSize: Int
  var uploadProgress: ((Int64) -> Void)?
  let maxRetries: Int
  
  var response: DefaultDataResponse?
  var responseEtag: String?
  var didFail: Bool
  
  private var retriesLeft: Int
  private var fileHandle: FileHandle?
  private var partChunkSize: Int
  
  private var beforeCommitCheckPointOperation: BlockOperation?
  private let chunkUploadOperationUnderlyingQueue = DispatchQueue(label: "com.filestack.chunk-upload-operation-queue",
                                                                  qos: .utility,
                                                                  attributes: .concurrent)
  private let chunkUploadOperationQueue = OperationQueue()
  
  required init(seek: UInt64,
                localURL: URL,
                fileName: String,
                fileSize: UInt64,
                apiKey: String,
                part: Int,
                uri: String,
                region: String,
                uploadID: String,
                storeOptions: StorageOptions,
                chunkSize: Int,
                chunkUploadConcurrency: Int,
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
    self.storeOptions = storeOptions
    self.chunkSize = chunkSize
    self.partChunkSize = 0
    self.maxRetries = 5
    self.retriesLeft = maxRetries
    self.didFail = false
    self.uploadProgress = uploadProgress
    self.chunkUploadOperationQueue.underlyingQueue = chunkUploadOperationUnderlyingQueue
    self.chunkUploadOperationQueue.maxConcurrentOperationCount = chunkUploadConcurrency
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
    chunkUploadOperationQueue.cancelAllOperations()
  }
}

private extension MultipartInteligentUploadSubmitPartOperation {
  func upload() {
    if isCancelled {
      state = .finished
      return
    }

    state = .executing
    partChunkSize = resumableMobileChunkSize
    
    beforeCommitCheckPointOperation = BlockOperation()
    
    beforeCommitCheckPointOperation?.completionBlock = {
      self.doCommit()
    }
    
    var partOffset: UInt64 = 0
    
    while partOffset < UInt64(chunkSize) {
      if isCancelled || isFinished {
        chunkUploadOperationQueue.cancelAllOperations()
        break
      }
      
      guard let chunkOperation = addChunkOperation(partOffset: partOffset,
                                                   partChunkSize: partChunkSize) else {
                                                    // EOF condition
                                                    break
      }
      
      partOffset += UInt64(chunkOperation.dataChunk.count)
    }
    
    if let beforeCommitCheckPointOperation = beforeCommitCheckPointOperation {
      chunkUploadOperationQueue.addOperation(beforeCommitCheckPointOperation)
    }
  }
  
  private func doCommit() {
    // Try to commit operation with retries.
    while !didFail && retriesLeft > 0 {
      let commitOperation = MultipartUploadCommitOperation(apiKey: apiKey,
                                                           fileSize: fileSize,
                                                           part: part,
                                                           uri: uri,
                                                           region: region,
                                                           uploadID: uploadID,
                                                           storeOptions: storeOptions)
      
      chunkUploadOperationQueue.addOperation(commitOperation)
      chunkUploadOperationQueue.waitUntilAllOperationsAreFinished()
      
      let jsonResponse = commitOperation.response
      let isNetworkError = jsonResponse?.response == nil && jsonResponse?.error != nil
      
      // Check for any error response.
      if (jsonResponse?.response?.statusCode != 200 || isNetworkError) && retriesLeft > 0 {
        let delay = isNetworkError ? 0 : pow(2, Double(self.maxRetries - retriesLeft))
        // Retrying in `delay` seconds
        Thread.sleep(forTimeInterval: delay)
      } else {
        break
      }
      
      retriesLeft -= 1
    }
    
    if retriesLeft == 0 {
      didFail = true
    }
    
    fileHandle = nil
    uploadProgress = nil
    state = .finished
    beforeCommitCheckPointOperation = nil
  }
  
  private func addChunkOperation(partOffset: UInt64, partChunkSize: Int) -> MultipartUploadSubmitChunkOperation? {
    guard let fileHandle = fileHandle else { return nil }
    
    fileHandle.seek(toFileOffset: self.seek + partOffset)
    let dataChunk = fileHandle.readData(ofLength: partChunkSize)
    
    guard dataChunk.count > 0 else { return nil }
    
    let operation = chunkOperation(partOffset: partOffset, dataChunk: dataChunk)
    
    weak var weakOperation = operation
    
    let checkpointOperation = BlockOperation {
      guard let operation = weakOperation else { return }
      guard operation.isCancelled == false else { return }
      
      // Network error
      if operation.receivedResponse?.error != nil {
        guard self.retriesLeft > 0 else {
          self.failOperation()
          return
        }
        
        self.retriesLeft -= 1
        
        guard self.addChunkOperation(partOffset: operation.partOffset,
                                     partChunkSize: self.partChunkSize) != nil else { return }
        // Server error
      } else if let response = operation.receivedResponse?.response {
        switch response.statusCode {
        case 200:
          
          let chunkSize = Int64(dataChunk.count)
          self.uploadProgress?(chunkSize)
          
        default:
          
          guard partChunkSize > self.minimumPartChunkSize else {
            self.failOperation()
            return
          }
          
          // Enqueue 2 chunks corresponding to the 2 halves of the failed chunk.
          let newPartChunkSize = partChunkSize / 2
          self.partChunkSize = newPartChunkSize
          var localPartOffset = operation.partOffset
          
          for _ in 1...2 {
            guard self.addChunkOperation(partOffset: localPartOffset,
                                         partChunkSize: newPartChunkSize) != nil else { break }
            
            localPartOffset += UInt64(newPartChunkSize)
          }
        }
      }
    }
    
    checkpointOperation.addDependency(operation)
    chunkUploadOperationQueue.addOperation(operation)
    chunkUploadOperationQueue.addOperation(checkpointOperation)
    
    beforeCommitCheckPointOperation?.addDependency(operation)
    beforeCommitCheckPointOperation?.addDependency(checkpointOperation)
    
    return operation
  }
  
  func chunkOperation(partOffset: UInt64, dataChunk: Data) -> MultipartUploadSubmitChunkOperation {
    return MultipartUploadSubmitChunkOperation(partOffset: partOffset,
                                               dataChunk: dataChunk,
                                               apiKey: apiKey,
                                               part: part,
                                               uri: uri,
                                               region: region,
                                               uploadID: uploadID,
                                               storeOptions: storeOptions)
  }

  func failOperation() {
    didFail = true
    state = .finished
    chunkUploadOperationQueue.cancelAllOperations()
  }
}
