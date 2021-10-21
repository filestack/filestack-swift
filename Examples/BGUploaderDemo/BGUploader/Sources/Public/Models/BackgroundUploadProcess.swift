//
//  BackgroundUploadProcess.swift
//  BGUploader
//
//  Created by Ruben Nine on 20/10/21.
//

import Foundation

public class BackgroundUploadProcess: Codable {
    /// Contains the upload tasks currently in progress.
    public var tasks: [Int: BackgroundUploadTaskResult] = [:]
}
