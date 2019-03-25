//
//  RequestBuilder.swift
//  Buya
//
//  Created by Eric Basargin on 02/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import Foundation
import RxSwift

public class RequestBuilder: RequestBuilderProtocol {
    private let addressManager: AddressManagerProtocol
    
    public init(addressManager: AddressManagerProtocol) {
        self.addressManager = addressManager
    }
    
    public func makeRequest(_ endpoint: EndpointType) -> Single<URLRequest> {
        if endpoint.requestType == RequestType.get, case RequestInfo.body(_) = endpoint.requestInfo {
            return Single.error(RequestBuilderError.invalidGetRequest)
        }

        switch endpoint.requestInfo {
        case RequestInfo.none:
            return self.requestPlain(endpoint)
            
        case RequestInfo.query:
            return self.requestQueryParameters(endpoint)
            
        case RequestInfo.body:
            return self.requestDataParameters(endpoint)
            
        case RequestInfo.common:
            return self.requestCompositeParameters(endpoint)
            
        case RequestInfo.bodyData:
            return self.requestData(endpoint)
            
        case RequestInfo.commonData:
            return self.requestCompositeData(endpoint)
        }
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

extension RequestBuilder: RequestBuilderFunctionality {
    func requestPlain(_ endpoint: EndpointType) -> Single<URLRequest> {
        guard case RequestInfo.none = endpoint.requestInfo else {
            return Single.error(RequestBuilderError.invalidEndpoint)
        }
        
        var url = self.addressManager.url
        url.appendPathComponent(endpoint.path)
        
        var request = URLRequest(url: url, timeoutInterval: endpoint.requestTimeout)
        
        if let headers: [String: String] = endpoint.headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        request.httpMethod = endpoint.requestType.rawValue
        
        return Single.just(request)
    }
    
    func requestData(_ endpoint: EndpointType) -> Single<URLRequest> {
        guard case let RequestInfo.bodyData(data) = endpoint.requestInfo else {
            return Single.error(RequestBuilderError.invalidEndpoint)
        }
        
        var url = self.addressManager.url
        url.appendPathComponent(endpoint.path)
    
        var request: URLRequest = URLRequest(url: url, timeoutInterval: endpoint.requestTimeout)
        request.httpBody = data
        
        if let headers: [String: String] = endpoint.headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        request.httpMethod = endpoint.requestType.rawValue
        
        return Single.just(request)
    }
    
    func requestCompositeData(_ endpoint: EndpointType) -> Single<URLRequest> {
        guard case let RequestInfo.commonData(parameters, data) = endpoint.requestInfo else {
            return Single.error(RequestBuilderError.invalidEndpoint)
        }
        
        var url = self.addressManager.url
        url.appendPathComponent(endpoint.path)
        
        guard let components: URLComponents = URLComponents(string: url.absoluteString) else {
            return Single.error(RequestBuilderError.invalidUrl)
        }
        
        if let url = self.makeUrlWithQuery(components: components, from: parameters) {
            var request: URLRequest = URLRequest(url: url, timeoutInterval: endpoint.requestTimeout)
            
            if let headers: [String: String] = endpoint.headers {
                for (key, value) in headers {
                    request.addValue(value, forHTTPHeaderField: key)
                }
            }
            
            request.httpMethod = endpoint.requestType.rawValue
            request.httpBody = data
            
            return Single.just(request)
        } else {
            return Single.error(RequestBuilderError.invalidParameters)
        }
    }
    
    func requestQueryParameters(_ endpoint: EndpointType) -> Single<URLRequest> {
        guard case let RequestInfo.query(parameters) = endpoint.requestInfo else {
            return Single.error(RequestBuilderError.invalidEndpoint)
        }
        
        var url = self.addressManager.url
        url.appendPathComponent(endpoint.path)
        
        guard let components: URLComponents = URLComponents(string: url.absoluteString) else {
            return Single.error(RequestBuilderError.invalidUrl)
        }

        if let url = self.makeUrlWithQuery(components: components, from: parameters) {
            var request: URLRequest = URLRequest(url: url, timeoutInterval: endpoint.requestTimeout)

            if let headers: [String: String] = endpoint.headers {
                for (key, value) in headers {
                    request.addValue(value, forHTTPHeaderField: key)
                }
            }
            
            request.httpMethod = endpoint.requestType.rawValue
            
            return Single.just(request)
        } else {
            return Single.error(RequestBuilderError.invalidParameters)
        }
    }
    
    func requestDataParameters(_ endpoint: EndpointType) -> Single<URLRequest> {
        guard case let RequestInfo.body(parameters) = endpoint.requestInfo else {
            return Single.error(RequestBuilderError.invalidEndpoint)
        }
        
        var url = self.addressManager.url
        url.appendPathComponent(endpoint.path)
        
        var request: URLRequest = URLRequest(url: url, timeoutInterval: endpoint.requestTimeout)
        
        do {
            let data = try JSONSerialization.data(withJSONObject: parameters, options: endpoint.writingOptions)
            request.httpBody = data
        } catch {
            return Single.error(RequestBuilderError.jsonEncodingFailed(error: error))
        }
        
        if let headers: [String: String] = endpoint.headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        request.httpMethod = endpoint.requestType.rawValue
        
        return Single.just(request)
    }
    
    func requestCompositeParameters(_ endpoint: EndpointType) -> Single<URLRequest> {
        guard case let RequestInfo.common(urlParameters, bodyParameters) = endpoint.requestInfo else {
            return Single.error(RequestBuilderError.invalidEndpoint)
        }
        
        var url = self.addressManager.url
        url.appendPathComponent(endpoint.path)
        
        guard let components: URLComponents = URLComponents(string: url.absoluteString) else {
            return Single.error(RequestBuilderError.invalidUrl)
        }
        
        if let url = self.makeUrlWithQuery(components: components, from: urlParameters) {
            var request: URLRequest = URLRequest(url: url, timeoutInterval: endpoint.requestTimeout)
            
            do {
                let data = try JSONSerialization.data(withJSONObject: bodyParameters, options: endpoint.writingOptions)
                request.httpBody = data
            } catch {
                return Single.error(RequestBuilderError.jsonEncodingFailed(error: error))
            }
            
            if let headers: [String: String] = endpoint.headers {
                for (key, value) in headers {
                    request.addValue(value, forHTTPHeaderField: key)
                }
            }
            
            request.httpMethod = endpoint.requestType.rawValue
            
            return Single.just(request)
        } else {
            return Single.error(RequestBuilderError.invalidParameters)
        }
    }
}
