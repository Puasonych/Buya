//
//  Single+Data.swift
//  Buya
//
//  Created by Eric Basargin on 05/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import Foundation
import RxSwift

public extension Single where Element == Data {
    func map<T: Decodable>(_ type: T.Type, using decoder: JSONDecoder = JSONDecoder()) -> Single<T> {
        return self.asObservable().flatMap({ (data) -> Observable<T> in
            do {
                return Observable.just(try decoder.decode(type, from: data))
            } catch {
                return Observable.error(error)
            }
        }).asSingle()
    }
}
