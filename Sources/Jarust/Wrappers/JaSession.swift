//
//  JaSession.swift
//
//
//  Created by Hamza Jadid on 22/01/2024.
//

import Foundation

public class JaSession {
    let session: RawJaSession
    let ctx: JaContext

    var onAttachSuccessCallback: ((RawJaHandle) -> Void)?
    var onAttachFailureCallback: (() -> Void)?

    var onAttachEchotestSuccessCallback: ((RawEchotestHandle) -> Void)?
    var onAttachEchotestFailureCallback: (() -> Void)?

    public init(from session: RawJaSession, ctx: JaContext) {
        self.session = session
        self.ctx = ctx
    }

    public func attach(
        pluginId: String,
        onSuccess: @escaping (JaHandle) -> Void,
        onFailure: @escaping () -> Void
    ) {
        self.onAttachSuccessCallback = { [ctx = ctx] rawHandle in
            onSuccess(JaHandle(from: rawHandle, ctx: ctx))
        }
        self.onAttachFailureCallback = onFailure
        self.session.attach(ctx: self.ctx.intoRaw, pluginId: pluginId, cb: self)
    }

    public func attachEchotest(
        onSuccess: @escaping (EchotestHandle) -> Void,
        onFailure: @escaping () -> Void
    ) {
        self.onAttachEchotestSuccessCallback = { [ctx = ctx] echotestHandle in
            onSuccess(EchotestHandle(from: echotestHandle, ctx: ctx))
        }
        self.onAttachEchotestFailureCallback = onFailure
        self.session.attachEchotest(ctx: self.ctx.intoRaw, cb: self)
    }
}

extension JaSession: RawJaSessionCallback {
    public func onAttachEchotestSuccess(handle: RawEchotestHandle) {
        self.onAttachEchotestSuccessCallback?(handle)
    }
    
    public func onAttachEchotestFailure() {
        self.onAttachEchotestFailureCallback?()
    }
    
    public func onAttachSuccess(handle: RawJaHandle) {
        self.onAttachSuccessCallback?(handle)
    }

    public func onAttachFailure() {
        self.onAttachFailureCallback?()
    }
}
