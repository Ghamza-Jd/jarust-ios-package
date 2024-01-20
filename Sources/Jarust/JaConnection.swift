//
//  JaConnection.swift
//
//
//  Created by Hamza Jadid on 17/01/2024.
//

import Foundation

public class JaConnection {
    let connection: RawJaConnection

    public init() throws {
        connection = try RawJaConnection()
    }

    public func connect(config: JaConfig) {
        connection.connect(config: config.intoRaw(), cb: self)
    }
}

extension JaConnection: RawJaCallback {
    public func onConnectionSuccess() { }

    public func onConnectionFailure() { }
}
