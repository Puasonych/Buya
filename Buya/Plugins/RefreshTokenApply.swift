//
//  RefreshTokenApply.swift
//  Buya
//
//  Created by Eric Basargin on 03/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import Foundation
import RxSwift

// MARK: - RefreshTokenApply

/// A protocol for controlling the behavior of `RefreshTokenPlugin`.
public protocol RefreshTokenApply {
    /// Add refresh token to request
    var refreshTokenApply: Bool { get }
}

// MARK: - RefreshTokenPlugin

public struct RefreshTokenPlugin: PluginType {
    
    /// A closure returning the refresh token.
    public let refreshTokenClosure: () -> String?
    
    /**
     Initialize a new `RefreshTokenPlugin`.
     
     - parameters:
     - refreshTokenClosure: A closure returning the refresh token to be applied in query parameter.
     */
    public init(refreshTokenClosure: @escaping () -> String?) {
        self.refreshTokenClosure = refreshTokenClosure
    }
    
    /**
     Prepare a request by adding a quary if necessary.
     
     - parameters:
     - request: The request to modify.
     - target: The target of the request.
     - returns: The modified `URLRequest`.
     */
    public func prepare(_ request: URLRequest, endpoint: EndpointType) -> URLRequest {
        guard let refresh = endpoint as? RefreshTokenApply else { return request }
        
        let recoveryAccess = refresh.refreshTokenApply
        var request = request
        
        if recoveryAccess, let refreshToken = self.refreshTokenClosure() {
            guard let urlString = request.url?.absoluteString else { return request }
            guard var components = URLComponents(string: urlString) else { return request }
            
            let queryItems: [URLQueryItem] = [URLQueryItem(name: "refreshToken", value: refreshToken)]
            
            components.queryItems = queryItems
            
            guard let url = components.url else { return request }
            request.url = url
        }
        
        return request
    }
}
