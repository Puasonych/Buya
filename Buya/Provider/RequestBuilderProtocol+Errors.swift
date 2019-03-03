//
//  RequestBuilderProtocol+Errors.swift
//  Buya
//
//  Created by Eric Basargin on 02/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import Foundation

enum RequestBuilderError: Error, LocalizedError {
    case invalidUrl
    case invalidParameters
    
    var errorDescription: String? {
        switch self {
        case .invalidUrl:
            return "Неверный URL (RequestBuilderError)"
        case .invalidParameters:
            return "Переданы неверные Query параметры запроса (RequestBuilderError)"
        }
    }
}
