//
//  BackgroundUploadTaskResult.swift
//  BGUploader
//
//  Created by Ruben Nine on 20/10/21.
//

import Foundation

public class BackgroundUploadTaskResult: Codable {
    /// The `URL` that is to be uploaded.
    public let url: URL

    /// The current status for this task.
    public internal(set) var status: Status = .started

    /// Default initializer.
    ///
    /// - Parameter url: The `URL` that is going to be uploaded.
    init(url: URL) {
        self.url = url
    }
}

extension BackgroundUploadTaskResult {
    public enum Status: Equatable, Codable {
        case started
        case completed(response: StoreResponse)
        case failed(error: BGUploadService.Error)
    }
}
