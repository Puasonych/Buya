
//
//  Error+Extensions.swift
//  Buya
//
//  Created by Eric Basargin on 04/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import Foundation
import RxCocoa

public extension Error {
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
