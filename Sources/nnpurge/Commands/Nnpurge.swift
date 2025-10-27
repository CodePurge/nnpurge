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
        version: "0.2.0",
        subcommands: [
            DeleteDerivedData.self,
            SetDerivedDataPath.self,
            DeletePackageCache.self
        ]
    )

    nonisolated(unsafe) static var contextFactory: ContextFactory = DefaultContextFactory()
}

extension Nnpurge {
    static func makePicker() -> any CommandLinePicker {
        return contextFactory.makePicker()
    }
    static func makeUserDefaults() -> any DerivedDataStore {
        return contextFactory.makeUserDefaults()
    }

    static func makeDerivedDataController() -> DerivedDataController {
        return DerivedDataController(picker: makePicker(), service: DerivedDataManager())
    }

    static func makeDerivedDataManager() -> any DerivedDataDelegate {
        return contextFactory.makeDerivedDataManager(defaults: makeUserDefaults())
    }

    static func makePackageCacheManager() -> any PackageCacheDelegate {
        return contextFactory.makePackageCacheManager()
    }
}
