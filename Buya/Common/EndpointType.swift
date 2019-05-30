//
//  EndpointType.swift
//  Buya
//
//  Created by Eric Basargin on 02/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import Foundation

public protocol EndpointType {
    typealias PercentEncodedQueryClosure = (String?) -> String?
    
    var reuseNumber: Int { get }
    
    var path: String { get }
    
    var requestType: RequestType { get }
    
    var requestInfo: RequestInfo { get }
    
    var requestCachePolicy: URLRequest.CachePolicy { get }
    
    var requestTimeout: TimeInterval { get }
    
    var headers: [String: String]? { get }
    
    var writingOptions: JSONSerialization.WritingOptions { get }
    
    var percentEncodedQuery: PercentEncodedQueryClosure? { get }
}

public extension EndpointType {
    var reuseNumber: Int { return 1 }
    
    var requestCachePolicy: URLRequest.CachePolicy { return URLRequest.CachePolicy.useProtocolCachePolicy }
    
    var requestTimeout: TimeInterval { return 60.0 }
    
    var writingOptions: JSONSerialization.WritingOptions { return [] }
    
    var percentEncodedQuery: PercentEncodedQueryClosure? {
        // TODO: - Pitfall #1: The + sign https://www.djackson.org/why-we-do-not-use-urlcomponents/
        return { (percentEncodedQuery) -> String? in
            return percentEncodedQuery?
                .replacingOccurrences(of: "+", with: "%2B")
                .replacingOccurrences(of: "%20", with: "+")
        }
    }
}
