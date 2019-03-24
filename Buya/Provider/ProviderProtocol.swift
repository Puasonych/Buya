//
//  ProviderProtocol.swift
//  Buya
//
//  Created by Eric Basargin on 07/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import Foundation
import RxSwift

public protocol ProviderProtocol: class {
    associatedtype Endpoint: EndpointType
    
    func request(_ endpoint: Endpoint, index: Int) -> Single<Data>
}
