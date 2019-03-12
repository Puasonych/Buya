//
//  Provider+Errors.swift
//  Buya
//
//  Created by Eric Basargin on 04/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import Foundation

public enum ProviderError: Error, LocalizedError {
    case invalidReuseEndpoint(_ endpoint: EndpointType)
    
    public var errorDescription: String? {
        switch self {
        case ProviderError.invalidReuseEndpoint(let endpoint):
            return "The request %s was repeated more than %d (%s)".providerLocalized(arguments: endpoint.path, endpoint.reuseNumber, "\(self)")
        }
    }
}
