//
//  RequestBuilder+Errors.swift
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
    case invalidEndpoint
    
    public var errorDescription: String? {
        switch self {
        case RequestBuilderError.invalidUrl:
            return "Invalid url (%s)".requestBuilderLocalized(arguments: "\(self)")
        case RequestBuilderError.invalidGetRequest:
            return "GET request can not contain Body (%s)".requestBuilderLocalized(arguments: "\(self)")
        case RequestBuilderError.invalidParameters:
            return "Invalid query parameters (%s)".requestBuilderLocalized(arguments: "\(self)")
        case RequestBuilderError.jsonEncodingFailed(let error):
            return "JSON serialization failed with an underlying system error during the encoding process; Error: %s (%s)".requestBuilderLocalized(arguments: error.localizedDescription, "\(self)")
        case RequestBuilderError.invalidEndpoint:
            return "Invalid endpoint (%s)".requestBuilderLocalized(arguments: "\(self)")
        }
    }
}
