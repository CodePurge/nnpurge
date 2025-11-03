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
            DerivedDataCommand.self
        ]
    )

    nonisolated(unsafe) static var contextFactory: ContextFactory = DefaultContextFactory()
}


// MARK: - Factory Methods
extension Nnpurge {
    static func makePicker() -> any CommandLinePicker {
        return contextFactory.makePicker()
    }

    static func makeUserDefaults() -> any DerivedDataStore {
        return contextFactory.makeUserDefaults()
    }

    static func makeDerivedDataService(path: String) -> any DerivedDataService {
        return contextFactory.makeDerivedDataService(path: path)
    }
}


// MARK: - Dependencies
protocol ContextFactory {
    func makePicker() -> any CommandLinePicker
    func makeUserDefaults() -> any DerivedDataStore
    func makeDerivedDataService(path: String) -> any DerivedDataService
}
