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
}

extension JaConnection: RawJaCallback {
    public func onConnectionSuccess(connection: RawJaConnection) {
        self.rawConnection = connection
        self.onConnectionSuccessCallback?()
    }

    public func onConnectionFailure() {
        self.onConnectionSuccessCallback?()
    }
}
