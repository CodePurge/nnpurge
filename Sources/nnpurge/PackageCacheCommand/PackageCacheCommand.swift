//
//  PackageCacheCommand.swift
//  Nnpurge
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Foundation
import CodePurgeKit
import ArgumentParser

extension Nnpurge {
    struct PackageCacheCommand: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "package-cache",
            abstract: "Manage Swift Package Manager caches",
            subcommands: [
                Delete.self,
                Clean.self,
//                Open.self
            ]
        )
    }
}


// MARK: - Delete
extension Nnpurge.PackageCacheCommand {
    struct Delete: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Deletes Swift Package Manager cached repositories"
        )

        @Flag(name: .shortAndLong, help: "Deletes all cached package repositories.")
        var all: Bool = false

        func run() throws {
            try Nnpurge.makePackageCacheController().deletePackageCache(deleteAll: all)
        }
    }
}


// MARK: - Clean
extension Nnpurge.PackageCacheCommand {
    struct Clean: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Deletes cached packages for the current project's dependencies"
        )

        @Option(name: .shortAndLong, help: "Path to the project directory (defaults to current directory)")
        var path: String?

        func run() throws {
            try Nnpurge.makePackageCacheController().cleanProjectDependencies(projectPath: path)
        }
    }
}


// MARK: - Open
extension Nnpurge.PackageCacheCommand {
    struct Open: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Open the Swift Package cache folder in Finder"
        )

        func run() throws {
            try Nnpurge.makePackageCacheController().openPackageCacheFolder()
            print("Opening package cache folder...")
        }
    }
}
