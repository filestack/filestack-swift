//
//  UserDefaults+Settings.swift
//  BGUploader
//
//  Created by Ruben Nine on 20/10/21.
//

import Foundation

extension UserDefaults {
    @UserDefault(key: "backgroundUploadProcess", defaultValue: BackgroundUploadProcess())
    static var backgroundUploadProcess: BackgroundUploadProcess
}
