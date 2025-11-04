//
//  ArchiveCommand.swift
//  Nnpurge
//
//  Created by Nikolai Nobadi on 11/4/25.
//

import Foundation
import CodePurgeKit
import ArgumentParser

extension Nnpurge {
    struct ArchiveCommand: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "archive",
            abstract: "Manage Xcode archives",
            subcommands: [
                Delete.self,
                Open.self
            ]
        )
    }
}


// MARK: - Delete
extension Nnpurge.ArchiveCommand {
    struct Delete: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Deletes Xcode archives"
        )

        @Flag(name: .shortAndLong, help: "Deletes all archive folders.")
        var all: Bool = false

        func run() throws {
            try Nnpurge.makeArchiveController().deleteArchives(deleteAll: all)
        }
    }
}


// MARK: - Open
extension Nnpurge.ArchiveCommand {
    struct Open: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Open the Xcode archives folder in Finder"
        )

        func run() throws {
            try Nnpurge.makeArchiveController().openArchiveFolder()
            print("Opening archives folder...")
        }
    }
}


// MARK: - Extension Dependencies
private extension Nnpurge {
    static func makeArchiveController() -> ArchiveController {
        let picker = Nnpurge.makePicker()
        let progressHandler = ConsoleProgressBar()
        let service = Nnpurge.makeArchiveService()

        return .init(picker: picker, service: service, progressHandler: progressHandler)
    }
}
