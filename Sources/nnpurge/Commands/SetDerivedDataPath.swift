//
//  SetDerivedDataPath.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import ArgumentParser
import Foundation

extension nnpurge {
    /// Command used to store a custom DerivedData path.
    struct SetDerivedDataPath: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "sdp",
            abstract: "Sets the path where derived data is located"
        )

        @Argument(help: "Path to Xcode's DerivedData folder")
        var path: String

        /// Persists the expanded path in ``UserDefaults`` and prints feedback
        /// to the user.
        func run() throws {
            let expandedPath = NSString(string: path).expandingTildeInPath
            let userDefaults = nnpurge.makeUserDefaults()
            userDefaults.set(expandedPath, forKey: "derivedDataPath")
            print("Derived data path set to \(expandedPath)")
        }
    }
}
