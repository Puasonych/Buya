//
//  NetworkWorkerProtocol.swift
//  Hostess
//
//  Created by Кирилл Салтыков on 29/01/2019.
//  Copyright © 2019 Basargin Erik. All rights reserved.
//

import Foundation
import RxSwift

protocol NetworkWorkerProtocol: class {
    func performRequest(_ request: URLRequest) -> Single<Data>
}
