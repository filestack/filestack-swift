//
//  Logger.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 01/07/2020.
//  Copyright © 2020 Filestack. All rights reserved.
//

import os.log

private class BundleFinder {}

extension OSLog {
    private static var subsystem = Bundle(for: BundleFinder.self).bundleIdentifier!

    /// Logs any issues related to file uploading.
    static let uploads = OSLog(subsystem: subsystem, category: "uploads")
}
