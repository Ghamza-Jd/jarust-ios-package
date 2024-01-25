//
//  JaHandle.swift
//
//
//  Created by Hamza Jadid on 24/01/2024.
//

import Foundation

public struct JaHandle {
    var rawHandle: RawJaHandle

    public init(from handle: RawJaHandle) {
        self.rawHandle = handle
    }
}
