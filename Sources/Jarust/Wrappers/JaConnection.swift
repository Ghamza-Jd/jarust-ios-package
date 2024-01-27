//
//  JaConnection.swift
//
//
//  Created by Hamza Jadid on 17/01/2024.
//

import Foundation

public class JaConnection {
    var rawConnection: RawJaConnection?
    var ctx: JaContext

    var onConnectionSuccessCallback: (() -> Void)?
    var onConnectionFailureCallback: (() -> Void)?
    var onSessionCreationSuccessCallback: ((RawJaSession) -> Void)?
    var onSessionCreationFailureCallback: (() -> Void)?

    public init(ctx: JaContext) {
        self.ctx = ctx
    }

    public func connect(
        config: JaConfig,
        onSuccess: @escaping () -> Void,
        onFailure: @escaping () -> Void
    ) {
        self.onConnectionSuccessCallback = onSuccess
        self.onConnectionFailureCallback = onFailure
        rawJarustConnect(ctx: self.ctx.intoRaw, config: config.intoRaw, cb: self)
    }

    public func createSession(
        keepAliveInterval: UInt32,
        onSuccess: @escaping (JaSession) -> Void,
        onFailure: @escaping () -> Void
    ) {
        self.onSessionCreationSuccessCallback = { [ctx = ctx] rawSession in
            onSuccess(JaSession(from: rawSession, ctx: ctx))
        }
        self.onSessionCreationFailureCallback = onFailure
        self.rawConnection?.create(ctx: self.ctx.intoRaw, kaInterval: keepAliveInterval, cb: self)
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
