//
//  Helpers.swift
//  FilestackSDKTests
//
//  Created by Ruben Nine on 30/09/2020.
//

import Foundation

class Helpers {
    static func url(forResource resource: String, withExtension ext: String?, subdirectory: String?) -> URL? {
        #if SWIFT_PACKAGE
        let bundle = Bundle.module
        #else
        let bundle = Bundle(for: Helpers.self)
        #endif

        return bundle.url(forResource: resource, withExtension: ext, subdirectory: subdirectory)
    }
}
