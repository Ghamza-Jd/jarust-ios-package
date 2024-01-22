//
//  JaSession.swift
//
//
//  Created by Hamza Jadid on 22/01/2024.
//

import Foundation

public struct JaSession {
    let session: RawJaSession

    public init(from session: RawJaSession) {
        self.session = session
    }
}
