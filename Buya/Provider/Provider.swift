//
//  Provider.swift
//  Buya
//
//  Created by Eric Basargin on 02/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import Foundation
import RxSwift

public class Provider<Endpoint: EndpointType>: ProviderProtocol {
    private let requestBuilder: RequestBuilderProtocol
    private let networkWorker: NetworkWorkerProtocol
    private let plugins: [PluginType]
    
    public init(requestBuilder: RequestBuilderProtocol,
                plugins: [PluginType] = [],
                networkWorker: NetworkWorkerProtocol? = nil) {
        self.requestBuilder = requestBuilder
        self.plugins = plugins
        if let worker = networkWorker {
            self.networkWorker = worker
        } else {
            self.networkWorker = NetworkWorker()
        }
    }
    
    public func request(_ endpoint: Endpoint) -> Single<Data> {
        assert(endpoint.reuseNumber >= 1, "endpoint.reuseNumber cannot be less than 1".providerLocalized())
        
        return request(endpoint, index: 0)
    }
    
    internal func request(_ endpoint: Endpoint, index: Int = 0) -> Single<Data> {
        if index > endpoint.reuseNumber {
            return Single.error(ProviderError.invalidReuseEndpoint(endpoint))
        }
        
        return self.requestBuilder
            .makeRequest(endpoint)
            .flatMap { (urlRequest) -> Single<Data> in
                var urlRequest = urlRequest
                
                for plugin in self.plugins {
                    urlRequest = plugin.prepare(urlRequest, endpoint: endpoint)
                }
                
                var result = self.networkWorker.performRequest(urlRequest)
                
                for plugin in self.plugins {
                    result = plugin.process(result, endpoint: endpoint, provider: self, index: index)
                }
                
                return result
            }
    }
}
