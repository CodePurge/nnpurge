//
//  Nnpurge+Extensions.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import Foundation
import ArgumentParser
@testable import nnpurge

extension Nnpurge {
    @discardableResult
    static func testRun(contextFactory: MockContextFactory? = nil, args: [String]? = []) throws -> String {
        self.contextFactory = contextFactory ?? MockContextFactory()
        return try captureOutput(factory: contextFactory, args: args)
    }
}

private extension Nnpurge {
    static func captureOutput(factory: MockContextFactory? = nil, args: [String]?) throws -> String {
        let pipe = Pipe()
        let readHandle = pipe.fileHandleForReading
        let writeHandle = pipe.fileHandleForWriting

        let originalStdout = dup(STDOUT_FILENO)
        dup2(writeHandle.fileDescriptor, STDOUT_FILENO)

        var command = try Self.parseAsRoot(args)
        try command.run()

        fflush(stdout)
        dup2(originalStdout, STDOUT_FILENO)
        close(originalStdout)
        writeHandle.closeFile()

        let data = readHandle.readDataToEndOfFile()
        readHandle.closeFile()

        return String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
