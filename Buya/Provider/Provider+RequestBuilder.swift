//
//  Provider+RequestBuilder.swift
//  Buya
//
//  Created by Eric Basargin on 02/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import Foundation
import RxSwift

public protocol RequestBuilderProtocol: class {
    associatedtype Endpoint: EndpointType
    
    func createURLRequest(_ endpoint: Endpoint) -> Single<URLRequest>
}

extension Provider: RequestBuilderProtocol {
    public func createURLRequest(_ endpoint: Endpoint) -> Single<URLRequest> {
        var url = self.addressManager.url
        url.appendPathComponent(endpoint.path)
        
        guard let components: URLComponents = URLComponents(string: url.absoluteString) else {
            return Single.error(RequestBuilderError.invalidUrl)
        }
        
        var request: URLRequest
        
        switch endpoint.requestInfo {
        case RequestInfo.none:
            if let timeout = endpoint.timeout {
                request = URLRequest(url: url, timeoutInterval: timeout)
            } else {
                request = URLRequest(url: url)
            }
            
        case RequestInfo.query(let parameters):
            guard let url = self.makeUrlWithQuery(components: components, from: parameters) else { return Single.error(RequestBuilderError.invalidParameters) }
            
            if let timeout = endpoint.timeout {
                request = URLRequest(url: url, timeoutInterval: timeout)
            } else {
                request = URLRequest(url: url)
            }
            
        case RequestInfo.body(let parameters):
            if let timeout = endpoint.timeout {
                request = URLRequest(url: url, timeoutInterval: timeout)
            } else {
                request = URLRequest(url: url)
            }
            
            do {
                let data = try JSONSerialization.data(withJSONObject: parameters, options: endpoint.writingOptions)
                request.httpBody = data
            } catch {
                return Single.error(RequestBuilderError.jsonEncodingFailed(error: error))
            }
            
        case RequestInfo.common(let urlParameters, let bodyParameters):
            guard let url = self.makeUrlWithQuery(components: components, from: urlParameters) else { return Single.error(RequestBuilderError.invalidParameters) }
            
            if let timeout = endpoint.timeout {
                request = URLRequest(url: url, timeoutInterval: timeout)
            } else {
                request = URLRequest(url: url)
            }
            
            do {
                let data = try JSONSerialization.data(withJSONObject: bodyParameters, options: endpoint.writingOptions)
                request.httpBody = data
            } catch {
                return Single.error(RequestBuilderError.jsonEncodingFailed(error: error))
            }
            
        case RequestInfo.bodyData(let data):
            if let timeout = endpoint.timeout {
                request = URLRequest(url: url, timeoutInterval: timeout)
            } else {
                request = URLRequest(url: url)
            }
            
            request.httpBody = data
            break
            
        case RequestInfo.commonData(let urlParameters, let bodyData):
            guard let url = self.makeUrlWithQuery(components: components, from: urlParameters) else { return Single.error(RequestBuilderError.invalidParameters) }
            
            if let timeout = endpoint.timeout {
                request = URLRequest(url: url, timeoutInterval: timeout)
            } else {
                request = URLRequest(url: url)
            }
            
            request.httpBody = bodyData
            break
        }
        
        if let headers: [String: String] = endpoint.headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        request.httpMethod = endpoint.requestType.rawValue
        
        return Single.just(request)
    }
    
    private func makeUrlWithQuery(components: URLComponents, from parameters: [String: String]) -> URL? {
        var components = components
        var queryItems: [URLQueryItem] = []
        
        for (key, value) in parameters {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        components.queryItems = queryItems
        
        return components.url
    }
}
