//
//  RequestBuilderProtocol.swift
//  Buya
//
//  Created by Eric Basargin on 07/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import Foundation
import RxSwift

public protocol RequestBuilderProtocol: class {
    func makeRequest(_ endpoint: EndpointType) -> Single<URLRequest>
}

protocol RequestBuilderFunctionality {
    func requestPlain(_ endpoint: EndpointType) -> Single<URLRequest>
    
    func requestData(_ endpoint: EndpointType) -> Single<URLRequest>
    
    func requestCompositeData(_ endpoint: EndpointType) -> Single<URLRequest>
    
    func requestQueryParameters(_ endpoint: EndpointType) -> Single<URLRequest>
    
    func requestDataParameters(_ endpoint: EndpointType) -> Single<URLRequest>
    
    func requestCompositeParameters(_ endpoint: EndpointType) -> Single<URLRequest>
}
