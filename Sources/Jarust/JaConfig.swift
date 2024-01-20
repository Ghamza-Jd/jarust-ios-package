//
//  JaConfig.swift
//
//
//  Created by Hamza Jadid on 20/01/2024.
//

import Foundation

public struct JaConfig {
    let uri: String
    let apisecret: String?
    let rootNamespace: String?

    public init(uri: String, apisecret: String? = nil, rootNamespace: String? = nil) {
        self.uri = uri
        self.apisecret = apisecret
        self.rootNamespace = rootNamespace
    }

    func intoRaw() -> RawJaConfig {
        .init(uri: self.uri, apisecret: self.apisecret, rootNamespace: self.rootNamespace)
    }
}
