//
//  StartUploadOperation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/19/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Alamofire
import Foundation

class StartUploadOperation: BaseOperation<UploadDescriptor> {
    // MARK: - Private Properties

    private let config: Config
    private let options: UploadOptions
    private let reader: UploadableReader
    private let filename: String
    private let filesize: UInt64
    private let mimeType: String

    // MARK: - Lifecycle

    required init(config: Config,
                  options: UploadOptions,
                  reader: UploadableReader,
                  filename: String,
                  filesize: UInt64,
                  mimeType: String) {
        self.config = config
        self.options = options
        self.reader = reader
        self.filename = filename
        self.filesize = filesize
        self.mimeType = mimeType

        super.init()
    }
}

// MARK: - Overrides

extension StartUploadOperation {
    override func main() {
        let uploadURL = URL(string: "multipart/start", relativeTo: Constants.uploadURL)!

        UploadService.upload(multipartFormData: multipartFormData, url: uploadURL, completionHandler: handleResponse)
    }
}

// MARK: - Private Functions

private extension StartUploadOperation {
    func handleResponse(response: JSONResponse) {
        // Ensure that there's a response and JSON payload or fail.
        guard let json = response.json else {
            self.finish(with: .failure(Error.custom("Unable to obtain JSON from /multipart/start response.")))
            return
        }

        // Did the REST API return an error? Fail and send the error downstream.
        if let apiErrorDescription = json["error"] as? String {
            self.finish(with: .failure(Error.custom("API Error: \(apiErrorDescription)")))
            return
        }

        // Ensure that there's an uri, region, and upload_id in the JSON payload or fail.
        guard let uri = json["uri"] as? String,
              let region = json["region"] as? String,
              let uploadID = json["upload_id"] as? String
        else {
            self.finish(with: .failure(Error.custom("JSON payload is missing required parameters.")))
            return
        }

        // Detect whether intelligent ingestion is available.
        // The JSON payload should contain an "upload_type" field with value "intelligent_ingestion".
        let canUseIntelligentIngestion: Bool

        if let uploadType = json["upload_type"] as? String, uploadType == "intelligent_ingestion" {
            canUseIntelligentIngestion = true
        } else {
            canUseIntelligentIngestion = false
        }

        let descriptor = UploadDescriptor(
            config: config,
            options: options,
            reader: reader,
            filename: filename,
            filesize: filesize,
            mimeType: mimeType,
            uri: uri,
            region: region,
            uploadID: uploadID,
            useIntelligentIngestion: canUseIntelligentIngestion
        )

        finish(with: .success(descriptor))
    }

    func multipartFormData(form: MultipartFormData) {
        form.append(config.apiKey, named: "apikey")
        form.append(filename, named: "filename")
        form.append(mimeType, named: "mimetype")
        form.append(String(filesize), named: "size")

        options.storeOptions.append(to: form)

        if let security = config.security {
            form.append(security.encodedPolicy, named: "policy")
            form.append(security.signature, named: "signature")
        }

        if options.preferIntelligentIngestion {
            form.append("true", named: "multipart")
        }
    }
}
