//
//  EchotestHandle.swift
//
//
//  Created by Hamza Jadid on 25/02/2024.
//

import Foundation

public class EchotestHandle {
    let rawHandle: RawEchotestHandle
    let ctx: JaContext
    var onResultCallback: ((EchotestResult) -> Void)?

    public init(from handle: RawEchotestHandle, ctx: JaContext) {
        self.rawHandle = handle
        self.ctx = ctx
        self.rawHandle.assignHandler(ctx: self.ctx.intoRaw, cb: self)
    }

    public func start(message: RawEchotestStartMsg) {
        self.rawHandle.start(ctx: self.ctx.intoRaw, msg: message)
    }
}

public struct EchotestResult {
    let echotest: String
    let result: String
}

extension EchotestHandle: RawEchotestEventsCallback {
    public func onResult(echotest: String, result: String) {
        onResultCallback?(.init(echotest: echotest, result: result))
    }
}
