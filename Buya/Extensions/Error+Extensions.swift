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
        return RxCocoaURLError.isHttpRequestFailed(error: self, at: 401)
    }
    
    var isBadRequest: Bool {
        return RxCocoaURLError.isHttpRequestFailed(error: self, at: 400)
    }
    
    var isInternalServerError: Bool {
        return RxCocoaURLError.isHttpRequestFailed(error: self, at: 500)
    }
    
    var isClientError: Bool {
        return RxCocoaURLError.isHttpRequestFailed(error: self, in: (400..<500))
    }
    
    var isServerError: Bool {
        return RxCocoaURLError.isHttpRequestFailed(error: self, in: (500..<600))
    }
}
