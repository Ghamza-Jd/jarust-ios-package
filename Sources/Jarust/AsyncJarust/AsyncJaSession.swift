//
//  File.swift
//  
//
//  Created by Hamza Jadid on 22/01/2024.
//

import Foundation

public actor AsyncJaSession {
    let session: JaSession

    init(from session: JaSession) {
        self.session = session
    }

    public func attach(ctx: JaContext, pluginId: String) async -> AsyncJaHandle? {
        await withCheckedContinuation { continuation in
            session.attach(
                ctx: ctx,
                pluginId: pluginId,
                onSuccess: { continuation.resume(returning: .init(from: $0)) },
                onFailure: { continuation.resume(returning: nil) }
            )
        }
    }
}
