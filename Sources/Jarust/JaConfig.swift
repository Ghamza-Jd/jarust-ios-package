//
//  JaConfig.swift
//
//
//  Created by Hamza Jadid on 20/01/2024.
//

import Foundation

public struct JaConfig {
    let rawConfig: RawJaConfig

    var intoRaw: RawJaConfig {
        rawConfig
    }

    public init(uri: String, apisecret: String? = nil, rootNamespace: String? = nil) {
        self.rawConfig = .init(uri: uri, apisecret: apisecret, rootNamespace: rootNamespace)
    }
}
