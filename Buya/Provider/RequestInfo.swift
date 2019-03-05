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
    case query(_ parameters: [String: String])
    case body(_ data: Data)
    case common(_ bodyData: Data, _ urlParameters: [String: String])
}
