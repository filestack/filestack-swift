//
//  Transformable+Deprecated.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 10/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import Foundation

extension Transformable {
    // MARK: - Deprecated

    /**
     Stores a copy of the transformation results to your preferred filestore.

     - Parameter fileName: Change or set the filename for the converted file.
     - Parameter location: An `StorageLocation` value.
     - Parameter path: Where to store the file in your designated container. For S3, this is
     the key where the file will be stored at.
     - Parameter container: The name of the bucket or container to write files to.
     - Parameter region: S3 specific parameter. The name of the S3 region your bucket is located
     in. All regions except for `eu-central-1` (Frankfurt), `ap-south-1` (Mumbai),
     and `ap-northeast-2` (Seoul) will work.
     - Parameter access: An `StorageAccess` value.
     - Parameter base64Decode: Specify that you want the data to be first decoded from base64
     before being written to the file. For example, if you have base64 encoded image data,
     you can use this flag to first decode the data before writing the image file.
     - Parameter queue: The queue on which the completion handler is dispatched.
     - Parameter completionHandler: Adds a handler to be called once the request has finished.
     */
    @objc
    @available(*, deprecated, message: "Marked for removal in version 3.0. Use the new store(using:base64Decode:queue:completionHandler) instead")
    @discardableResult
    public func store(fileName: String? = nil,
                      location: StorageLocation,
                      path: String? = nil,
                      container: String? = nil,
                      region: String? = nil,
                      access: StorageAccess,
                      base64Decode: Bool,
                      queue: DispatchQueue? = .main,
                      completionHandler: @escaping (FileLink?, NetworkJSONResponse) -> Void) -> Self {
        let options = StorageOptions(location: location,
                                     region: region,
                                     container: container,
                                     path: path,
                                     filename: fileName,
                                     access: access)

        return store(using: options, base64Decode: base64Decode, queue: queue, completionHandler: completionHandler)
    }
}
