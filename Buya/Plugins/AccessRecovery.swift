//
//  AccessRecovery.swift
//  Buya
//
//  Created by Eric Basargin on 03/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// A protocol for controlling the behavior of `AccessRecoveryPlugin`.
public protocol AccessRecovery {
    /// Represents the recovery of access to use for requests.
    var accessRecovery: Bool { get }
}

public struct AccessRecoveryPlugin: PluginType {
    /// A closure restoring access.
    public let accessRecoveryClosure: () -> Single<Data>
    
    /// A closure is called when `accessRecoveryClosure` returns a 401 error.
    public let onBadRequest: ((Error) -> Void)?
    
    /// A closure is called when `accessRecoveryClosure` returns any error came
    public let onError: ((Error) -> Void)?
    
    /**
     Initialize a new `AccessRecoveryPlugin`.
     
     - Parameter accessRecoveryClosure: Restoring access clouser
     */
    public init(accessRecoveryClosure: @escaping () -> Single<Data>,
                onBadRequest: ((Error) -> Void)? = nil,
                onError: ((Error) -> Void)? = nil) {
        self.accessRecoveryClosure = accessRecoveryClosure
        self.onBadRequest = onBadRequest
        self.onError = onError
    }
    
    public func process<Endpoint>(_ result: Single<Data>, endpoint: Endpoint, provider: Provider<Endpoint>, index: Int) -> Single<Data> where Endpoint : EndpointType {
        guard let recovery = endpoint as? AccessRecovery else { return result }
        
        if !recovery.accessRecovery { return result }
        
        let onBadRequest = self.onBadRequest
        let onError = self.onError
        
        return result
            .catchError { (error) -> Single<Data> in
                if !error.isUnauthorized { return result }
                
                return self.accessRecoveryClosure()
                    .catchError({ (error) -> Single<Data> in
                        onError?(error)
                        
                        if error.isBadRequest { onBadRequest?(error) }

                        return error.isBadRequest ? result : Single.error(error)
                    })
                    .flatMap({ (_) -> Single<Data> in
                        return provider.request(endpoint, index: index + 1)
                    })
            }
    }
}
