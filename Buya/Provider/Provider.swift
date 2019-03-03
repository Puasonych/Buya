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
    let addressManager: AddressManagerProtocol
    let networkWorker: NetworkWorkerProtocol
    let jsonEncoder: JSONEncoder
    
    init(addressManager: AddressManagerProtocol,
         networkWorker: NetworkWorkerProtocol = NetworkWorker(),
         jsonEncoder: JSONEncoder = JSONEncoder()) {
        self.addressManager = addressManager
        self.networkWorker = networkWorker
        self.jsonEncoder = jsonEncoder
    }
    
    public func request(_ endpoint: Endpoint) -> Single<Data> {
        return self.createURLRequest(endpoint).flatMap { (urlRequest) -> Single<Data> in
            return self.networkWorker.performRequest(urlRequest)
        }
    }
}
