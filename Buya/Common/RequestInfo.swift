//
//  RequestInfo.swift
//  Buya
//
//  Created by Eric Basargin on 02/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import Foundation

public enum RequestInfo {
    case none
    case query(parameters: [String: String])
    case body(parameters: [String: Any])
    case common(urlParameters: [String: String], bodyParameters: [String: Any])
    case bodyData(data: Data)
    case commonData(urlParameters: [String: String], bodyData: Data)
}
