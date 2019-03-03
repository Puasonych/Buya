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

// MARK: - AccessRecovery

/// A protocol for controlling the behavior of `AccessRecoveryPlugin`.
public protocol AccessRecovery {
    /// Represents the recovery of access to use for requests.
    var accessRecovery: Bool { get }
    
    /// Maximum number of retries on failed request
    var retriesNumber: UInt { get }
}

extension AccessRecovery {
    var retriesNumber: UInt { return 3 }
}

// MARK: - AccessRecoveryPlugin

public struct AccessRecoveryPlugin: PluginType {
    
    /// A closure returning the refresh token.
    public let accessRecoveryClosure: () -> Single<Data>
    
    /**
     Initialize a new `AccessRecoveryPlugin`.
     
     - parameters:
     - accessRecoveryClosure: Restoring access clouser
     */
    public init(accessRecoveryClosure: @escaping () -> Single<Data>) {
        self.accessRecoveryClosure = accessRecoveryClosure
    }
    
    /**
     Prepare a request by adding a quary if necessary.
     
     - parameters:
     - result: The result before completion.
     - target: The target of the request.
     - returns: The result of the main request or error.
     */
    public func process<Endpoint>(_ result: Single<Data>, endpoint: Endpoint, provider: Provider<Endpoint>) -> Single<Data> where Endpoint : EndpointType {
        guard let recovery = endpoint as? AccessRecovery else { return result }
        
        if !recovery.accessRecovery { return result }
        let retriesNumber = recovery.retriesNumber
        
        return result
            .catchError { (error) -> Single<Data> in
                if error.isUnauthorized {
                    return self.accessRecoveryClosure()
                        .retryWhen({ (error) -> Observable<Void> in
                            return error.enumerated().flatMap({ (index, error) -> Observable<Void> in
                                if error.isUnauthorized, index <= retriesNumber { return Observable.error(error) }
                                return Observable.just(())
                            })
                        })
                        .catchError({ (error) -> Single<Data> in
                            if error.isBadRequest { return result }
                            return Single.error(error)
                        })
                        .flatMap({ (_) -> Single<Data> in
                            return provider.request(endpoint)
                        })
                }
                return result
            }
    }
}

private extension Error {
    var isUnauthorized: Bool {
        if let error = self as? RxCocoa.RxCocoaURLError {
            switch error {
            case .httpRequestFailed(response: let response, data: _):
                return response.statusCode == 401
            default:
                return false
            }
        }
        
        return false
    }
    
    var isBadRequest: Bool {
        if let error = self as? RxCocoa.RxCocoaURLError {
            switch error {
            case .httpRequestFailed(response: let response, data: _):
                return response.statusCode == 400
            default:
                return false
            }
        }
        
        return false
    }
}
