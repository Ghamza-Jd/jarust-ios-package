//
//  AsyncJaConnection.swift
//
//
//  Created by Hamza Jadid on 20/01/2024.
//

import Foundation

public actor AsyncJaConnection {
    let connection: JaConnection

    public init() {
        connection = JaConnection()
    }

    public func connect(ctx: JaContext, config: JaConfig) async {
        await withCheckedContinuation { continuation in
            connection.connect(
                ctx: ctx,
                config: config,
                onSuccess: { continuation.resume() },
                onFailure: { continuation.resume() }
            )
        }
    }

    public func createSession(ctx: JaContext, keepAliveInterval: UInt32) async -> AsyncJaSession? {
        await withCheckedContinuation { continuation in
            connection.createSession(
                ctx: ctx,
                keepAliveInterval: keepAliveInterval,
                onSuccess: { session in continuation.resume(returning: .init(from: session)) },
                onFailure: { continuation.resume(returning: nil)}
            )
        }
    }
}
