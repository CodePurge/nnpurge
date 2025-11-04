//
//  ProjectDependencies.swift
//  Nnpurge
//
//  Created by Nikolai Nobadi on 11/4/25.
//

import Foundation

/// Represents dependencies from a Swift Package Manager Package.resolved file
public struct ProjectDependencies: Codable {
    let pins: [Pin]
    let version: Int

    struct Pin: Codable {
        let identity: String
        let kind: String
        let location: String
        let state: State

        struct State: Codable {
            let revision: String
            let version: String?
        }
    }
}

public extension ProjectDependencies {
    /// Extracts all package identities from the resolved dependencies
    var packageIdentities: [String] {
        pins.map { $0.identity }
    }
}
