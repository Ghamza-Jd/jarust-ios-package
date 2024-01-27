//
//  AsyncJaConnection.swift
//
//
//  Created by Hamza Jadid on 20/01/2024.
//

import Foundation

public actor AsyncJaConnection {
    let connection: JaConnection

    public init(ctx: JaContext) {
        connection = JaConnection(ctx: ctx)
    }

    public func connect(config: JaConfig) async {
        await withCheckedContinuation { continuation in
            connection.connect(
                config: config,
                onSuccess: { continuation.resume() },
                onFailure: { continuation.resume() }
            )
        }
    }

    public func createSession(keepAliveInterval: UInt32) async -> AsyncJaSession? {
        await withCheckedContinuation { continuation in
            connection.createSession(
                keepAliveInterval: keepAliveInterval,
                onSuccess: { session in continuation.resume(returning: .init(from: session)) },
                onFailure: { continuation.resume(returning: nil) }
            )
        }
    }
}
