//
//  AsyncJaHandle.swift
//
//
//  Created by Hamza Jadid on 24/01/2024.
//

import Foundation

public actor AsyncJaHandle {
    let handle: JaHandle

    init(from handle: JaHandle) {
        self.handle = handle
    }

    public func message(_ msg: String) {
        self.handle.message(msg)
    }

    public func events() -> AsyncStream<String> {
        AsyncStream { continuation in
            handle.onEventCallback = { evt in
                continuation.yield(evt)
            }
        }
    }
}
