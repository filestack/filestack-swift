//
//  NetworkingService.swift
//  FilestackSDK
//
//  Created by Ruben Nine on 7/6/17.
//  Copyright © 2017 Filestack. All rights reserved.
//

import Foundation

protocol NetworkingService {
    var session: URLSession { get }
}

protocol ProvidesBaseURL {
    var baseURL: URL { get }
}

protocol NetworkingServiceWithBaseURL: NetworkingService & ProvidesBaseURL {
    func buildURL(handle: String?, path: String?, extra: String?, queryItems: [URLQueryItem]?, security: Security?) -> URL?
}
