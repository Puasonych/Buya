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
    
    var timeout: TimeInterval? { get }
    
    var headers: [String: String]? { get }
}

public extension EndpointType {
    var reuseNumber: Int { return 1 }
    
    var timeout: TimeInterval? { return nil }
}
