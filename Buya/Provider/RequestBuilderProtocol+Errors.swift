//
//  RequestBuilderProtocol+Errors.swift
//  Buya
//
//  Created by Eric Basargin on 02/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import Foundation

public enum RequestBuilderError: Error, LocalizedError {
    case invalidUrl
    case invalidGetRequest
    case invalidParameters
    case jsonEncodingFailed(error: Error)
    
    public var errorDescription: String? {
        switch self {
        case RequestBuilderError.invalidUrl:
            return "Неверный URL (RequestBuilderError)"
        case RequestBuilderError.invalidGetRequest:
            return "Нельзя через GET запрос передать Body"
        case RequestBuilderError.invalidParameters:
            return "Переданы неверные Query параметры запроса (RequestBuilderError)"
        case RequestBuilderError.jsonEncodingFailed(let error):
            return "JSON serialization failed with an underlying system error during the encoding process. Error: \(error.localizedDescription)"
        }
    }
}
