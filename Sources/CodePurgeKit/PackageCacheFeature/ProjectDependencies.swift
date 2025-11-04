//
//  ProjectDependencies.swift
//  Nnpurge
//
//  Created by Nikolai Nobadi on 11/4/25.
//

import Foundation

public struct ProjectDependencies: Codable {
    let pins: [Pin]
    let version: Int

    public init(pins: [Pin], version: Int) {
        self.pins = pins
        self.version = version
    }

    public struct Pin: Codable {
        let identity: String
        let kind: String
        let location: String
        let state: State

        public init(identity: String, kind: String, location: String, state: State) {
            self.identity = identity
            self.kind = kind
            self.location = location
            self.state = state
        }

        public struct State: Codable {
            let revision: String
            let version: String?

            public init(revision: String, version: String?) {
                self.revision = revision
                self.version = version
            }
        }
    }
}

public extension ProjectDependencies {
    var packageIdentities: [String] {
        pins.map { $0.identity }
    }
}
