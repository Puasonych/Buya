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
    
    /// Maximum number of retries on failed request
    var retriesNumber: UInt { get }
}

public extension AccessRecovery {
    var retriesNumber: UInt { return 3 }
}

public struct AccessRecoveryPlugin: PluginType {
    /// A closure restoring access.
    public let accessRecoveryClosure: () -> Single<Data>
    
    /**
     Initialize a new `AccessRecoveryPlugin`.
     
     - Parameter accessRecoveryClosure: Restoring access clouser
     */
    public init(accessRecoveryClosure: @escaping () -> Single<Data>) {
        self.accessRecoveryClosure = accessRecoveryClosure
    }
    
    public func process<Endpoint>(_ result: Single<Data>, endpoint: Endpoint, provider: Provider<Endpoint>, index: Int) -> Single<Data> where Endpoint : EndpointType {
        guard let recovery = endpoint as? AccessRecovery else { return result }
        
        if !recovery.accessRecovery { return result }
        let retriesNumber = recovery.retriesNumber
        
        return result
            .catchError { (error) -> Single<Data> in
                if error.isUnauthorized {
                    return self.accessRecoveryClosure()
                        .retryWhen({ (error) -> Observable<Void> in
                            return error.enumerated().flatMap({ (index, error) -> Observable<Void> in
                                if error.isBadRequest || index < retriesNumber { return Observable.error(error) }
                                return Observable.just(())
                            })
                        })
                        .catchError({ (error) -> Single<Data> in
                            if error.isBadRequest { return result }
                            return Single.error(error)
                        })
                        .flatMap({ (_) -> Single<Data> in
                            return provider.request(endpoint, index: index + 1)
                        })
                }
                return result
            }
    }
}
