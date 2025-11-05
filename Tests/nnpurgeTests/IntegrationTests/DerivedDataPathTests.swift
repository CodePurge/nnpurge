//
//  DerivedDataPathTests.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Testing
import CodePurgeKit
import CodePurgeTesting
import SwiftPickerTesting
@testable import nnpurge

@MainActor
final class DerivedDataPathTests {
    @Test("Displays default path when no custom path is set")
    func displaysDefaultPathWhenNoCustomPathIsSet() throws {
        let (factory, store) = makeSUT()

        let output = try Nnpurge.testRun(contextFactory: factory, args: ["derived-data", "path"])

        #expect(output.contains("Library/Developer/Xcode/DerivedData"))
        #expect(output.contains("(using default)"))
        #expect(store.string(forKey: "derivedDataPathKey") == nil)
    }

    @Test("Displays custom path when custom path is set")
    func displaysCustomPathWhenCustomPathIsSet() throws {
        let customPath = "/custom/path/to/derived/data"
        let (factory, store) = makeSUT()
        store.set(customPath, forKey: "derivedDataPathKey")

        let output = try Nnpurge.testRun(contextFactory: factory, args: ["derived-data", "path"])

        #expect(output.contains(customPath))
        #expect(!output.contains("(using default)"))
    }

    @Test("Sets new path when set flag provided", arguments: ["-s", "--set"])
    func setsNewPathWhenSetFlagProvided(setFlag: String) throws {
        let newPath = "/new/custom/path"
        let (factory, store) = makeSUT()

        let output = try Nnpurge.testRun(contextFactory: factory, args: ["derived-data", "path", setFlag, newPath])

        #expect(output.contains("Derived data path set to"))
        #expect(output.contains(newPath))
        #expect(store.string(forKey: "derivedDataPathKey") == newPath)
    }

    @Test("Expands tilde when setting new path")
    func expandsTildeWhenSettingNewPath() throws {
        let pathWithTilde = "~/custom/derived/data"
        let (factory, store) = makeSUT()

        let output = try Nnpurge.testRun(contextFactory: factory, args: ["derived-data", "path", "--set", pathWithTilde])

        let storedPath = store.string(forKey: "derivedDataPathKey")
        #expect(storedPath != nil)
        #expect(!storedPath!.contains("~"))
        #expect(output.contains(storedPath!))
    }

    @Test("Resets to default path when reset flag provided", arguments: ["-r", "--reset"])
    func resetsToDefaultPathWhenResetFlagProvided(resetFlag: String) throws {
        let customPath = "/custom/path"
        let (factory, store) = makeSUT()
        store.set(customPath, forKey: "derivedDataPathKey")

        let output = try Nnpurge.testRun(contextFactory: factory, args: ["derived-data", "path", resetFlag])

        #expect(output.contains("Derived data path reset to default"))
        #expect(output.contains("~/Library/Developer/Xcode/DerivedData"))
        #expect(store.string(forKey: "derivedDataPathKey") == nil)
    }

    @Test("Clears stored path when reset flag provided")
    func clearsStoredPathWhenResetFlagProvided() throws {
        let customPath = "/custom/path"
        let (factory, store) = makeSUT()
        store.set(customPath, forKey: "derivedDataPathKey")
        #expect(store.string(forKey: "derivedDataPathKey") != nil)

        _ = try Nnpurge.testRun(contextFactory: factory, args: ["derived-data", "path", "--reset"])

        #expect(store.string(forKey: "derivedDataPathKey") == nil)
    }

    @Test("Opens default derived data folder when open subcommand invoked", .disabled()) // TODO: - enable once open feature is working
    func opensDefaultDerivedDataFolderWhenOpenSubcommandInvoked() throws {
        let (factory, store, service) = makeSUTWithService()

        let output = try Nnpurge.testRun(contextFactory: factory, args: ["derived-data", "open"])

        #expect(output.contains("Opening derived data folder"))
        let openedURL = try #require(service.openedFolderURL)
        #expect(openedURL.path.contains("Library/Developer/Xcode/DerivedData"))
        #expect(store.string(forKey: "derivedDataPathKey") == nil)
    }

    @Test("Opens custom derived data folder when custom path set", .disabled()) // TODO: - enable once open feature is working
    func opensCustomDerivedDataFolderWhenCustomPathSet() throws {
        let customPath = "/custom/derived/data/path"
        let store = MockUserDefaults()
        store.set(customPath, forKey: "derivedDataPathKey")
        let service = MockPurgeService()
        let picker = makePicker()
        let factory = MockContextFactory(
            picker: picker,
            derivedDataStore: store,
            purgeService: service
        )

        let output = try Nnpurge.testRun(contextFactory: factory, args: ["derived-data", "open"])

        #expect(output.contains("Opening derived data folder"))
        let openedURL = try #require(service.openedFolderURL)
        #expect(openedURL.path == customPath)
    }
}


// MARK: - SUT
private extension DerivedDataPathTests {
    func makeSUT() -> (factory: MockContextFactory, store: MockUserDefaults) {
        let store = MockUserDefaults()
        let service = MockPurgeService()
        let picker = makePicker()
        let factory = MockContextFactory(
            picker: picker,
            derivedDataStore: store,
            purgeService: service
        )

        return (factory, store)
    }

    func makeSUTWithService() -> (factory: MockContextFactory, store: MockUserDefaults, service: MockPurgeService) {
        let store = MockUserDefaults()
        let service = MockPurgeService()
        let picker = makePicker()
        let factory = MockContextFactory(
            picker: picker,
            derivedDataStore: store,
            purgeService: service
        )

        return (factory, store, service)
    }

    func makePicker() -> MockSwiftPicker {
        return MockSwiftPicker(
            permissionResult: .init(grantByDefault: true, type: .ordered([])),
            selectionResult: .init()
        )
    }
}
