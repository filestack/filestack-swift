//
//  CDNService.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 03/07/2017.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation
import Alamofire


internal class CDNService: NetworkingService {

    let baseURL = Config.cdnURL
    let sessionManager = SessionManager.filestackDefault()
}
