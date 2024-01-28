//
//  JaHandle.swift
//
//
//  Created by Hamza Jadid on 24/01/2024.
//

import Foundation

public class JaHandle {
    let rawHandle: RawJaHandle
    let ctx: JaContext
    var onEventCallback: ((String) -> Void)?

    public init(from handle: RawJaHandle, ctx: JaContext) {
        self.rawHandle = handle
        self.ctx = ctx
        self.rawHandle.assignHandler(ctx: self.ctx.intoRaw, cb: self)
    }

    public func message(_ msg: String) {
        self.rawHandle.message(ctx: self.ctx.intoRaw, message: msg)
    }
}

extension JaHandle: RawJaEventsCallback {
    public func onEvent(event: String) {
        self.onEventCallback?(event)
    }
}
