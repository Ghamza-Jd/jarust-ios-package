//
//  JaHandle.swift
//
//
//  Created by Hamza Jadid on 24/01/2024.
//

import Foundation

public struct JaHandle {
    let rawHandle: RawJaHandle
    let ctx: JaContext

    public init(from handle: RawJaHandle, ctx: JaContext) {
        self.rawHandle = handle
        self.ctx = ctx
    }
}
