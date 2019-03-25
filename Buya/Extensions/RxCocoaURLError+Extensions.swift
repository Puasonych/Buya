//
//  RxCocoaURLError+Extensions.swift
//  Buya
//
//  Created by Алексей Воронов on 25/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import Foundation
import RxCocoa

public extension RxCocoaURLError {
    static func isHttpRequestFailed(error: Error, at errorCode: Int) -> Bool {
        guard let error = error as? RxCocoaURLError else { return false }
        
        switch error {
        case let .httpRequestFailed(response: response, data: _):
            return response.statusCode == errorCode
        default:
            return false
        }
    }
    
    static func isHttpRequestFailed(error: Error, in errorCodes: Range<Int>) -> Bool {
        guard let error = error as? RxCocoaURLError else { return false }
        
        switch error {
        case let .httpRequestFailed(response: response, data: _):
            return errorCodes.contains(response.statusCode)
        default:
            return false
        }
    }
}
