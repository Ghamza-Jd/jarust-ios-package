//
//  JaContext.swift
//
//
//  Created by Hamza Jadid on 20/01/2024.
//

import Foundation

public struct JaContext {
    let ctx: RawJaContext

    public var intoRaw: RawJaContext {
        ctx
    }

    public init(numWorkers: UInt8? = nil, name: String? = nil) throws {
        self.ctx = try RawJaContext(numWorkers: numWorkers, name: name)
    }
}
