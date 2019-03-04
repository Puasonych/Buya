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
    /// Called to modify a request before sending.
    func prepare(_ request: URLRequest, endpoint: EndpointType) -> URLRequest
    
    /// Called to modify a result before completion.
    func process<Endpoint: EndpointType>(_ result: Single<Data>, endpoint: Endpoint, provider: Provider<Endpoint>, index: Int) -> Single<Data>
}

public extension PluginType {
    func prepare(_ request: URLRequest, endpoint: EndpointType) -> URLRequest { return request }
    func process<Endpoint: EndpointType>(_ result: Single<Data>, endpoint: Endpoint, provider: Provider<Endpoint>, index: Int) -> Single<Data> { return result }
}
