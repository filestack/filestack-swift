//
//  StoreResponse.swift
//  BGUploader
//
//  Created by Ruben Nine on 20/10/21.
//

import Foundation

/// `StoreResponse` represents the expected JSON object response when doing a POST against /api/store/S3.
public struct StoreResponse: Codable, Equatable {
    /// Filestack Handle (derived from `url`)
    public var handle: String { url.lastPathComponent }

    /// Filestack Handle URL.
    public let url: URL

    /// S3 container.
    public let container: String

    /// Filename (e.g. "pic1.jpg")
    public let filename: String

    /// Key used in S3 storage.
    public let key: String

    /// Mimetype (e.g. "image/jpeg")
    public let type: String

    /// Filesize (e.g. 5520262)
    public let size: Int
}
