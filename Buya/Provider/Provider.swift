//
//  Provider.swift
//  Buya
//
//  Created by Eric Basargin on 02/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import Foundation
import RxSwift

public protocol ProviderProtocol: class {
    associatedtype Endpoint: EndpointType
    
    func request(_ endpoint: Endpoint) -> Single<Data>
}

public class Provider<Endpoint: EndpointType>: ProviderProtocol {
    private let networkWorker: NetworkWorkerProtocol
    private let jsonEncoder: JSONEncoder
    private let plugins: [PluginType]
    
    let addressManager: AddressManagerProtocol
    
    public init(addressManager: AddressManagerProtocol,
         plugins: [PluginType] = [],
         networkWorker: NetworkWorkerProtocol?,
         jsonEncoder: JSONEncoder = JSONEncoder()) {
        self.addressManager = addressManager
        self.plugins = plugins
        if let worker = networkWorker {
            self.networkWorker = worker
        } else {
            self.networkWorker = NetworkWorker()
        }
        self.jsonEncoder = jsonEncoder
    }
    
    public func request(_ endpoint: Endpoint) -> Single<Data> {
        if endpoint.requestType == RequestType.get, case RequestInfo.body(_) = endpoint.requestInfo {
            return Single.error(RequestBuilderError.invalidGetRequest)
        }
        
        return self.createURLRequest(endpoint).flatMap { (urlRequest) -> Single<Data> in
            var urlRequest = urlRequest
            
            for plugin in self.plugins {
                urlRequest = plugin.prepare(urlRequest, endpoint: endpoint)
            }
            
            var result = self.networkWorker.performRequest(urlRequest)
            
            for plugin in self.plugins {
                result = plugin.process(result, endpoint: endpoint, provider: self)
            }
            
            return result
        }
    }
}
