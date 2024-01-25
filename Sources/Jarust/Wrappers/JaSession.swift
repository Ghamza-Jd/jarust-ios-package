//
//  JaSession.swift
//
//
//  Created by Hamza Jadid on 22/01/2024.
//

import Foundation

public class JaSession {
    let session: RawJaSession

    var onAttachSuccessCallback: ((RawJaHandle) -> Void)?
    var onAttachFailureCallback: (() -> Void)?

    public init(from session: RawJaSession) {
        self.session = session
    }

    public func attach(
        ctx: JaContext,
        pluginId: String,
        onSuccess: @escaping (JaHandle) -> Void,
        onFailure: @escaping () -> Void
    ) {
        self.onAttachSuccessCallback = { rawHandle in
            onSuccess(JaHandle(from: rawHandle))
        }
        self.onAttachFailureCallback = onFailure
        self.session.attach(ctx: ctx.intoRaw, pluginId: pluginId, cb: self)
    }
}

extension JaSession: RawJaSessionCallback {
    public func onAttachSuccess(handle: RawJaHandle) {
        self.onAttachSuccessCallback?(handle)
    }

    public func onAttachFailure() {
        self.onAttachFailureCallback?()
    }
}
