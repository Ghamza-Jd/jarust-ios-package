//
//  JaProtocol.swift
//
//
//  Created by Hamza Jadid on 27/02/2024.
//

import Foundation

public struct Jsep {
    let sdp: String
    let type: JsepType

    var intoRaw: RawJsep {
        switch self.type {
        case .offer:
            return .init(sdp: self.sdp, jsepType: .offer)

        case .answer:
            return .init(sdp: self.sdp, jsepType: .answer)
        }
    }

    public init(sdp: String, type: JsepType) {
        self.sdp = sdp
        self.type = type
    }
}
