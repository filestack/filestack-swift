//
//  StartUploadOperation.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/19/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

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
        let headers = ["Content-Type": "application/json"]

        guard let payload = self.payload() else { return }

        UploadService.shared.upload(data: payload, to: uploadURL, method: "POST", headers: headers) { (data, response, error) in
            let jsonResponse = JSONResponse(response: response, data: data, error: error)
            self.handleResponse(response: jsonResponse)
        }
    }
}

// MARK: - Private Functions

private extension StartUploadOperation {
    func handleResponse(response: JSONResponse) {
        // Ensure that there's a response and JSON payload or fail.
        guard let json = response.json else {
            finish(with: .failure(.custom("Unable to obtain JSON from /multipart/start response.")))
            return
        }

        // Did the REST API return an error? Fail and send the error downstream.
        if let apiErrorDescription = json["error"] as? String {
            finish(with: .failure(.api(apiErrorDescription)))
            return
        }

        // Ensure that there's an uri, region, and upload_id in the JSON payload or fail.
        guard let uri = json["uri"] as? String,
              let region = json["region"] as? String,
              let uploadID = json["upload_id"] as? String
        else {
            finish(with: .failure(.custom("JSON payload is missing required parameters.")))
            return
        }

        // Detect whether intelligent ingestion is available.
        // The JSON payload should contain an "upload_type" field with value "intelligent_ingestion".
        let canUseIntelligentIngestion = json["upload_type"] as? String == "intelligent_ingestion"

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

    func payload() -> Data? {
        var payload: [String: Any] = [
            "apikey": config.apiKey,
            "filename": filename,
            "mimetype": mimeType,
            "size": filesize,
            "store": options.storeOptions.asDictionary()
        ]

        if let security = config.security {
            payload["policy"] = security.encodedPolicy
            payload["signature"] = security.signature
        }

        if options.preferIntelligentIngestion {
            payload["fii"] = true
        }

        return try? JSONSerialization.data(withJSONObject: payload)
    }
}
