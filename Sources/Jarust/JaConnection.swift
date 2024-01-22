//
//  JaConnection.swift
//
//
//  Created by Hamza Jadid on 17/01/2024.
//

import Foundation

public class JaConnection {
    var rawConnection: RawJaConnection?

    var onConnectionSuccessCallback: (() -> Void)?
    var onConnectionFailureCallback: (() -> Void)?
    var onSessionCreationSuccessCallback: ((RawJaSession) -> Void)?
    var onSessionCreationFailureCallback: (() -> Void)?

    public func connect(
        ctx: JaContext, 
        config: JaConfig,
        onSuccess: @escaping () -> Void,
        onFailure: @escaping () -> Void
    ) {
        self.onConnectionSuccessCallback = onSuccess
        self.onConnectionFailureCallback = onFailure
        rawJarustConnect(ctx: ctx.intoRaw, config: config.intoRaw, cb: self)
    }

    public func createSession(
        ctx: JaContext,
        keepAliveInterval: UInt32,
        onSuccess: @escaping (JaSession) -> Void,
        onFailure: @escaping () -> Void
    ) {
        self.onSessionCreationSuccessCallback = { rawSession in
            onSuccess(JaSession(from: rawSession))
        }
        self.onSessionCreationFailureCallback = onFailure
        self.rawConnection?.create(kaInterval: keepAliveInterval, cb: self)
    }
}

extension JaConnection: RawJaConnectionCallback {
    public func onConnectionSuccess(connection: RawJaConnection) {
        self.rawConnection = connection
        self.onConnectionSuccessCallback?()
    }

    public func onConnectionFailure() {
        self.onConnectionSuccessCallback?()
    }

    public func onSessionCreationSuccess(session: RawJaSession) {
        self.onSessionCreationSuccessCallback?(session)
    }

    public func onSessionCreationFailure() {
        self.onSessionCreationFailureCallback?()
    }
}
