//
//  JarustConnection.swift
//
//
//  Created by Hamza Jadid on 17/01/2024.
//

import Foundation

public class JarustConnection {
    let connection: JaConnection

    public init() throws {
        connection = try JaConnection()
    }

    public func connect(config: JaConfig) {
        connection.connect(config: config, cb: self)
    }
}

extension JarustConnection: JaCallback {
    public func onConnectionSuccess() {

    }

    public func onConnectionFailure() {

    }
}
