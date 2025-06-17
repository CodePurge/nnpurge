//
//  SetDerivedDataPathTests.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import XCTest
@testable import nnpurge

final class SetDerivedDataPathTests: XCTestCase {
    func testRun_storesExpandedPath_andPrintsMessage() throws {
        let factory = MockContextFactory()
        let inputPath = "~/DerivedDataFolder"
        let expectedPath = NSString(string: inputPath).expandingTildeInPath

        let output = try nnpurge.testRun(contextFactory: factory, args: ["sdp", inputPath])

        XCTAssertEqual(factory.userDefaults.values["derivedDataPath"] as? String, expectedPath)
        XCTAssertEqual(output, "Derived data path set to \(expectedPath)")
    }
}
