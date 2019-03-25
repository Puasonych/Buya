//
//  EndpointType.swift
//  Buya
//
//  Created by Eric Basargin on 02/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import Foundation

public protocol EndpointType {
    var reuseNumber: Int { get }
    
    var path: String { get }
    
    var requestType: RequestType { get }
    
    var requestInfo: RequestInfo { get }
    
    var requestCachePolicy: URLRequest.CachePolicy { get }
    
    var requestTimeout: TimeInterval { get }
    
    var headers: [String: String]? { get }
    
    var writingOptions: JSONSerialization.WritingOptions { get }
}

public extension EndpointType {
    var reuseNumber: Int { return 1 }
    
    var requestCachePolicy: URLRequest.CachePolicy { return URLRequest.CachePolicy.useProtocolCachePolicy }
    
    var requestTimeout: TimeInterval { return 60.0 }
    
    var writingOptions: JSONSerialization.WritingOptions { return [] }
}
