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
            DerivedDataCommand.self,
            PackageCacheCommand.self,
            ArchiveCommand.self,
            DemoProgressCommand.self
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

    static func makePackageCacheService() -> any PackageCacheService {
        return contextFactory.makePackageCacheService()
    }

    static func makePackageCacheController() -> PackageCacheController {
        let picker = Nnpurge.makePicker()
        let service = Nnpurge.makePackageCacheService()
        let progressHandler = ConsoleProgressBar()

        return .init(picker: picker, service: service, progressHandler: progressHandler)
    }

    static func makeArchiveService() -> any ArchiveService {
        return contextFactory.makeArchiveService()
    }
}


// MARK: - Dependencies
protocol ContextFactory {
    func makePicker() -> any CommandLinePicker
    func makeUserDefaults() -> any DerivedDataStore
    func makeDerivedDataService(path: String) -> any DerivedDataService
    func makePackageCacheService() -> any PackageCacheService
    func makeArchiveService() -> any ArchiveService
}

import Foundation

struct DemoProgressCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "progress-demo",
        abstract: "Simulates progress for 70 items over 10 seconds."
    )

    func run() throws {
        let totalItems = 70
        let totalDuration: TimeInterval = 10
        let delay = totalDuration / Double(totalItems)
        var progressBar = ProgressBar(total: totalItems)

        for i in 1...totalItems {
            progressBar.update(to: i, message: "Processing item \(i) of \(totalItems)...")
            Thread.sleep(forTimeInterval: delay)
        }

        print("\n✅ Completed all \(totalItems) items.")
    }
}

struct ProgressBar {
    private let total: Int
    private let width: Int
    private var firstUpdate = true

    init(total: Int, width: Int = 50) {
        self.total = total
        self.width = width
    }

    mutating func update(to value: Int, message: String) {
        let progress = Double(value) / Double(total)
        let filled = Int(progress * Double(width))
        let empty = width - filled
        let bar = String(repeating: "█", count: filled) + String(repeating: "-", count: empty)
        let percent = String(format: "%.2f%%", progress * 100)

        if !firstUpdate {
            // Move cursor up two lines to overwrite previous message and bar
            print("\u{1B}[2A", terminator: "")
        } else {
            firstUpdate = false
        }

        // Clear both lines
        print("\u{1B}[2K\(message)")
        print("\u{1B}[2K\(bar) \(percent)")
        fflush(stdout)
    }
}
