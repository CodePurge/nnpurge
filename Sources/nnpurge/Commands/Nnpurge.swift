//
//  Nnpurge.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import SwiftPicker
import ArgumentParser

/// Root command for the `nnpurge` CLI tool.
///
/// Provides access to subcommands and exposes factory helpers used
/// throughout the application.
struct nnpurge: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A command-line tool to clean up Xcode's derived data folders with interactive prompts for safety and precision.",
        subcommands: [
            DeleteDerivedData.self,
            SetDerivedDataPath.self
        ]
    )

    nonisolated(unsafe) static var contextFactory: ContextFactory = DefaultContextFactory()
}

extension nnpurge {
    /// Creates a `Picker` using the current ``ContextFactory``.
    static func makePicker() -> Picker {
        return contextFactory.makePicker()
    }
    
    /// Creates a ``DerivedDataStore`` (``UserDefaults`` by default) using the
    /// current ``ContextFactory``.
    static func makeUserDefaults() -> DerivedDataStore {
        return contextFactory.makeUserDefaults()
    }

    /// Creates a ``DerivedDataDelegate`` responsible for loading and deleting
    /// derived data folders.
    static func makeDerivedDataManager() -> DerivedDataDelegate {
        return contextFactory.makeDerivedDataManager(defaults: makeUserDefaults())
    }
}
