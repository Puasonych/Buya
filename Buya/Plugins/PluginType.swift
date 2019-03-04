//
//  PluginType.swift
//  Buya
//
//  Created by Eric Basargin on 03/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import Foundation
import RxSwift

public protocol PluginType {
    /**
     Called to modify a request before sending.
     
     - Parameter request: The request to modify.
     - Parameter endpoint: The endpoint of the request.
     - returns: The modified `URLRequest`.
     */
    func prepare(_ request: URLRequest, endpoint: EndpointType) -> URLRequest
    
    /**
     Called to modify a result before completion.
     
     - Parameter result: The result before completion.
     - Parameter endpoint: The endpoint of the request.
     - Parameter provider: The current provider.
     - Parameter index: The request number.
     - returns: The result of the main request or error.
     */
    func process<Endpoint: EndpointType>(_ result: Single<Data>, endpoint: Endpoint, provider: Provider<Endpoint>, index: Int) -> Single<Data>
}

public extension PluginType {
    func prepare(_ request: URLRequest, endpoint: EndpointType) -> URLRequest { return request }
    func process<Endpoint: EndpointType>(_ result: Single<Data>, endpoint: Endpoint, provider: Provider<Endpoint>, index: Int) -> Single<Data> { return result }
}
