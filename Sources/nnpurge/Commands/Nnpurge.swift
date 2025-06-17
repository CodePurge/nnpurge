import SwiftPicker
import ArgumentParser

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
    static func makePicker() -> Picker {
        return contextFactory.makePicker()
    }
    
    static func makeUserDefaults() -> UserDefaultsProtocol {
        return contextFactory.makeUserDefaults()
    }

    static func makeDerivedDataManager() -> DerivedDataManaging {
        return contextFactory.makeDerivedDataManager(defaults: makeUserDefaults())
    }
}
