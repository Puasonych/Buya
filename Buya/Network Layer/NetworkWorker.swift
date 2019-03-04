//
//  NetworkWorker.swift
//  Hostess
//
//  Created by Кирилл Салтыков on 29/01/2019.
//  Copyright © 2019 Basargin Erik. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class NetworkWorker: NetworkWorkerProtocol {
    private let session: URLSession
    
    required init(session: URLSession = URLSession(configuration: .default)) {
        self.session = session
    }
    
    func performRequest(_ request: URLRequest) -> Single<Data> {
        return self.session.rx.data(request: request).asSingle()
    }
}
