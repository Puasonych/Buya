//
//  AccessTokenAuthorizable.swift
//  Buya
//
//  Created by Eric Basargin on 03/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import Foundation
import RxSwift

/// A protocol for controlling the behavior of `AccessTokenPlugin`.
public protocol AccessTokenAuthorizable {
    /// Represents the authorization header to use for requests.
    var authorizationType: AuthorizationType { get }
}

/// An enum representing the header to use with an `AccessTokenPlugin`
public enum AuthorizationType {
    /// No header.
    case none
    
    /// The `"Basic"` header.
    case basic
    
    /// The `"Bearer"` header.
    case bearer
    
    /// Custom header implementation.
    case custom(String)
    
    public var value: String? {
        switch self {
        case .none: return nil
        case .basic: return "Basic"
        case .bearer: return "Bearer"
        case let .custom(customValue): return customValue
        }
    }
}

/**
 A plugin for adding basic or bearer-type authorization headers to requests.
 
 ```
 Authorization: Basic <token>
 Authorization: Bearer <token>
 Authorization: <Сustom> <token>
 ```
 */
public struct AccessTokenPlugin: PluginType {
    /// A closure returning the access token to be applied in the header.
    public let tokenClosure: () -> String?
    
    /**
     Initialize a new `AccessTokenPlugin`.
     
     - Parameter tokenClosure: A closure returning the token to be applied in the pattern `Authorization: <AuthorizationType> <token>`
     */
    public init(tokenClosure: @escaping () -> String?) {
        self.tokenClosure = tokenClosure
    }
    
    public func prepare(_ request: URLRequest, endpoint: EndpointType) -> URLRequest {
        guard let authorizable = endpoint as? AccessTokenAuthorizable else { return request }
        
        let authorizationType = authorizable.authorizationType
        var request = request
        
        switch authorizationType {
        case .basic, .bearer, .custom:
            if let value = authorizationType.value, let token = self.tokenClosure() {
                let authValue = value + " " + token
                request.addValue(authValue, forHTTPHeaderField: "Authorization")
            }
        case .none:
            break
        }
        
        return request
    }
}
