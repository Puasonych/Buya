//
//  RefreshTokenApply.swift
//  Buya
//
//  Created by Eric Basargin on 03/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import Foundation
import RxSwift

/// This parameter defines the location of refresh token
public enum RefreshTokenLocation {
    case inQuery
    case inBody
}

/// A protocol for controlling the behavior of `RefreshTokenPlugin`.
public protocol RefreshTokenApply {
    /// Add refresh token to request
    var refreshTokenApply: Bool { get }
    
    /// This parameter defines the location of refresh token (body or query)
    var refreshTokenLocation: RefreshTokenLocation { get }
}

public extension RefreshTokenApply {
    var refreshTokenLocation: RefreshTokenLocation { return RefreshTokenLocation.inQuery }
}

public struct RefreshTokenPlugin: PluginType {
    /// A closure returning the refresh token.
    public let refreshTokenClosure: () -> String?
    
    /**
     Initialize a new `RefreshTokenPlugin`.
     
     - Parameter refreshTokenClosure: A closure returning the refresh token to be applied in query parameter.
     */
    public init(refreshTokenClosure: @escaping () -> String?) {
        self.refreshTokenClosure = refreshTokenClosure
    }
    
    public func prepare(_ request: URLRequest, endpoint: EndpointType) -> URLRequest {
        guard let refresh = endpoint as? RefreshTokenApply else { return request }
        
        let recoveryAccess = refresh.refreshTokenApply
        let refreshTokenLocation = refresh.refreshTokenLocation
        var request = request
        
        guard recoveryAccess, let refreshToken = self.refreshTokenClosure() else { return request }
        
        switch refreshTokenLocation {
        case RefreshTokenLocation.inQuery:
            guard let urlString = request.url?.absoluteString else { return request }
            guard var components = URLComponents(string: urlString) else { return request }
            
            let queryItems: [URLQueryItem] = [URLQueryItem(name: "refreshToken", value: refreshToken)]
            
            components.queryItems = queryItems
            
            guard let url = components.url else { return request }
            request.url = url
            
        case RefreshTokenLocation.inBody:
            let parameters: [String: String] = ["refreshToken": refreshToken]
            
            do {
                let data = try JSONSerialization.data(withJSONObject: parameters, options: endpoint.writingOptions)
                request.httpBody = data
            } catch {
                return request
            }
        }
        
        return request
    }
}
