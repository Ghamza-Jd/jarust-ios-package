//
//  AsyncEchotestHandle.swift
//
//
//  Created by Hamza Jadid on 27/02/2024.
//

import Foundation

public actor AsyncEchotestHandle {
    let handle: EchotestHandle

    init(from handle: EchotestHandle) {
        self.handle = handle
    }

    public func start(audio: Bool, video: Bool, bitrate: UInt32, jsep: Jsep) {
        self.handle.start(message: .init(audio: audio, video: video, bitrate: bitrate, jsep: jsep.intoRaw))
    }

    public func events() -> AsyncStream<EchotestEvents> {
        AsyncStream { continuation in
            handle.onResultCallback = { evt in
                continuation.yield(.result(echotest: evt.echotest, res: evt.result))
            }
        }
    }
}

public enum JsepType {
    case offer
    case answer
}

public enum EchotestEvents {
    case result(echotest: String, res: String)
}
