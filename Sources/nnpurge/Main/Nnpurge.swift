//
//  Nnpurge.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import SwiftPicker
import CodePurgeKit
import ArgumentParser

@main
struct Nnpurge: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A command-line tool to clean up Xcode's derived data folders with interactive prompts for safety and precision.",
        version: "v0.2.1",
        subcommands: [
            DerivedDataCommand.self,
            PackageCacheCommand.self,
//            ArchiveCommand.self
        ]
    )

    nonisolated(unsafe) static var contextFactory: ContextFactory = DefaultContextFactory()
}


// MARK: - Factory Methods
extension Nnpurge {
    static func makePicker() -> any PurgePicker {
        return contextFactory.makePicker()
    }

    static func makeUserDefaults() -> any DerivedDataStore {
        return contextFactory.makeUserDefaults()
    }

    static func makeDerivedDataService(path: String) -> any DerivedDataService {
        return contextFactory.makeDerivedDataService(path: path)
    }

    static func makePackageCacheService() -> any PackageCacheService {
        return contextFactory.makePackageCacheService()
    }
    
    static func makeArchiveService() -> any ArchiveService {
        return contextFactory.makeArchiveService()
    }

    static func makePackageCacheController() -> PackageCacheController {
        let picker = Nnpurge.makePicker()
        let service = Nnpurge.makePackageCacheService()
        let progressHandler = ConsoleProgressBar()

        return .init(picker: picker, service: service, progressHandler: progressHandler)
    }
}


// MARK: - Dependencies
protocol ContextFactory {
    func makePicker() -> any PurgePicker
    func makeUserDefaults() -> any DerivedDataStore
    func makeArchiveService() -> any ArchiveService
    func makePackageCacheService() -> any PackageCacheService
    func makeDerivedDataService(path: String) -> any DerivedDataService
}

