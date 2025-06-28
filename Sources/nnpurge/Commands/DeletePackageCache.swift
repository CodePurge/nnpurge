//
//  DeletePackageCache.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import ArgumentParser
import Files
import SwiftPicker
import Foundation

extension nnpurge {
    /// Command that removes cached Swift Package repositories.
    ///
    /// When run interactively the command will prompt the user for
    /// confirmation before deleting any folders.
    struct DeletePackageCache: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "spm",
            abstract: "Deletes cached Swift Package repositories"
        )

        @Flag(name: .shortAndLong, help: "Deletes all cached package repositories.")
        var all: Bool = false

        @Flag(name: .shortAndLong, help: "Opens the cached package repositories folder.")
        var open: Bool = false

        /// Executes the deletion command based on the provided options.
        func run() throws {
            if open {
                try openPackageCacheFolder()
                return
            }

            let picker = nnpurge.makePicker()
            let manager = nnpurge.makePackageCacheManager()
            var foldersToDelete = try manager.loadPackageFolders()

            if all {
                try picker.requiredPermission(prompt: "Are you sure you want to delete all cached package repositories?")
            } else {
                let selection = try picker.requiredSingleSelection("What would you like to do?", items: PackageCacheAction.allCases)

                switch selection {
                case .deleteAll:
                    try picker.requiredPermission(prompt: "Are you sure you want to delete all cached package repositories?")
                case .deleteSelectFolder:
                    foldersToDelete = picker.multiSelection("Select the repositories to delete.", items: foldersToDelete)
                case .openFolder:
                    try openPackageCacheFolder()
                    return
                }
            }

            try manager.moveFoldersToTrash(foldersToDelete)
        }

        /// Opens the cached Swift Package repositories folder in Finder.
        private func openPackageCacheFolder() throws {
            let path = "~/Library/Caches/org.swift.swiftpm/repositories"
            let expandedPath = NSString(string: path).expandingTildeInPath

            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
            process.arguments = [expandedPath]
            try process.run()
            process.waitUntilExit()
        }
    }
}
