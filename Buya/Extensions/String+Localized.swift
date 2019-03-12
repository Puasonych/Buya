//
//  String+Localized.swift
//  Buya
//
//  Created by Eric Basargin on 12/03/2019.
//  Copyright © 2019 Three-man army. All rights reserved.
//

import Foundation

extension String {
    func localized(bundle: Bundle = .main, tableName: String = "Localizable", arguments: CVarArg...) -> String {
        let mask: String = NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
        if arguments.isEmpty || mask == "**\(self)**" { return mask }
        return String(format: mask, arguments)
    }
    
    // MARK: - Provider
    func providerLocalized(arguments: CVarArg...) -> String {
        return self.localized(bundle: Bundle.main, tableName: "ProviderLocalization", arguments: arguments)
    }
    
    // MARK: - RequestBuilder
    func requestBuilderLocalized(arguments: CVarArg...) -> String {
        return self.localized(bundle: Bundle.main, tableName: "RequestBuilderLocalization", arguments: arguments)
    }
}
