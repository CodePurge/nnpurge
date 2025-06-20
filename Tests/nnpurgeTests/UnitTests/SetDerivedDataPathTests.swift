//
//  SetDerivedDataPathTests.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import Testing
import Foundation
@testable import nnpurge

/// Tests for the ``SetDerivedDataPath`` command.
struct SetDerivedDataPathTests {
    @Test("Run stores expanded path and prints message")
    /// Verifies that the command saves the expanded path and outputs confirmation.
    func testRun_storesExpandedPath_andPrintsMessage() throws {
        let factory = MockContextFactory()
        let inputPath = "~/DerivedDataFolder"
        let expectedPath = NSString(string: inputPath).expandingTildeInPath
        let output = try nnpurge.testRun(contextFactory: factory, args: ["sdp", inputPath])

        #expect(factory.userDefaults.values["derivedDataPath"] as? String == expectedPath)
        #expect(output == "Derived data path set to \(expectedPath)")
    }
}
