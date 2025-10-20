//
//  SetDerivedDataPath.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import Foundation
import ArgumentParser

extension nnpurge {
    struct SetDerivedDataPath: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "sdp",
            abstract: "Sets the path where derived data is located"
        )

        @Argument(help: "Path to Xcode's DerivedData folder")
        var path: String

        func run() throws {
            let expandedPath = NSString(string: path).expandingTildeInPath
            let userDefaults = nnpurge.makeUserDefaults()
            
            userDefaults.set(expandedPath, forKey: "derivedDataPath")
            print("Derived data path set to \(expandedPath)")
        }
    }
}
