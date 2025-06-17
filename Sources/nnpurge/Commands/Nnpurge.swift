import ArgumentParser

struct nnpurge: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A command-line tool to clean up Xcode's derived data folders with interactive prompts for safety and precision.",
        subcommands: [
            DeleteDerivedData.self,
            SetDerivedDataPath.self
        ]
    )
}
