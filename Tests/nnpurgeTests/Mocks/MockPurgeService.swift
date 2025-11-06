//
//  MockPurgeService.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Foundation
import CodePurgeKit
@testable import nnpurge

final class MockPurgeService: @unchecked Sendable, DerivedDataService, PackageCacheService {
    private let throwError: Bool
    private let throwDependencyError: Bool
    private let throwXcodeRunning: Bool
    private let closeXcodeSucceeds: Bool
    private let derivedDataFoldersToLoad: [DerivedDataFolder]
    private let packageCacheFoldersToLoad: [PackageCacheFolder]
    private let dependenciesToLoad: [String]

    private(set) var didDeleteAllDerivedData = false
    private(set) var deletedDerivedDataFolders: [DerivedDataFolder] = []
    private(set) var deletedPackageCacheFolders: [PackageCacheFolder] = []
    private(set) var receivedProgressHandler: PurgeProgressHandler?
    private(set) var didFindDependencies = false
    private(set) var searchedPath: String?
    private(set) var didCloseXcode = false
    private var xcodeRunningErrorThrown = false

    init(
        throwError: Bool = false,
        throwDependencyError: Bool = false,
        derivedDataFoldersToLoad: [DerivedDataFolder] = [],
        packageCacheFoldersToLoad: [PackageCacheFolder] = [],
        dependenciesToLoad: [String] = [],
        throwXcodeRunning: Bool = false,
        closeXcodeSucceeds: Bool = true
    ) {
        self.throwError = throwError
        self.throwDependencyError = throwDependencyError
        self.throwXcodeRunning = throwXcodeRunning
        self.closeXcodeSucceeds = closeXcodeSucceeds
        self.derivedDataFoldersToLoad = derivedDataFoldersToLoad
        self.packageCacheFoldersToLoad = packageCacheFoldersToLoad
        self.dependenciesToLoad = dependenciesToLoad
    }

}


// MARK: - DerivedDataService
extension MockPurgeService {
    func loadFolders() throws -> [DerivedDataFolder] {
        if throwError {
            throw NSError(domain: "TestError", code: 1)
        }

        return derivedDataFoldersToLoad
    }

    func deleteFolders(_ folders: [DerivedDataFolder], force: Bool, progressHandler: (any PurgeProgressHandler)?) throws {
        if throwError {
            throw NSError(domain: "TestError", code: 1)
        }

        if throwXcodeRunning && !force && !xcodeRunningErrorThrown {
            xcodeRunningErrorThrown = true
            throw DerivedDataError.xcodeIsRunning
        }

        receivedProgressHandler = progressHandler
        didDeleteAllDerivedData = true
        deletedDerivedDataFolders.append(contentsOf: folders)

        for (index, folder) in folders.enumerated() {
            progressHandler?.updateProgress(current: index + 1, total: folders.count, message: "Deleting \(folder.name)...")
        }

        progressHandler?.complete(message: "✅ Derived Data moved to trash.")
    }

    func closeXcodeAndVerify(timeout: TimeInterval) throws {
        didCloseXcode = true

        if !closeXcodeSucceeds {
            throw PackageCacheError.xcodeFailedToClose
        }
    }
}


// MARK: - PackageCacheService
extension MockPurgeService {
    func loadFolders() throws -> [PackageCacheFolder] {
        if throwError {
            throw NSError(domain: "TestError", code: 1)
        }

        return packageCacheFoldersToLoad
    }

    func findDependencies(in path: String?) throws -> ProjectDependencies {
        didFindDependencies = true
        searchedPath = path

        if throwDependencyError {
            throw NSError(domain: "TestError", code: 1)
        }

        let pins = dependenciesToLoad.map { identity in
            ProjectDependencies.Pin(
                identity: identity,
                kind: "remoteSourceControl",
                location: "https://github.com/test/\(identity)",
                state: .init(revision: "abc123", version: "1.0.0")
            )
        }

        return ProjectDependencies(pins: pins, version: 3)
    }

    func deleteFolders(_ folders: [PackageCacheFolder], force: Bool, progressHandler: (any PurgeProgressHandler)?) throws {
        if throwError {
            throw NSError(domain: "TestError", code: 1)
        }

        if throwXcodeRunning && !force && !xcodeRunningErrorThrown {
            xcodeRunningErrorThrown = true
            throw PackageCacheError.xcodeIsRunning
        }

        receivedProgressHandler = progressHandler
        deletedPackageCacheFolders.append(contentsOf: folders)

        for (index, folder) in folders.enumerated() {
            progressHandler?.updateProgress(current: index + 1, total: folders.count, message: "Deleting \(folder.name)...")
        }

        progressHandler?.complete(message: "✅ Package Repositories moved to trash.")
    }
}
