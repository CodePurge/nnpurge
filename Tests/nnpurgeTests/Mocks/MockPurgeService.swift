//
//  MockPurgeService.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Foundation
import CodePurgeKit
@testable import nnpurge

final class MockPurgeService: @unchecked Sendable, PurgeService, DerivedDataService, PackageCacheService {
    private let throwError: Bool
    private let throwDependencyError: Bool
    private let foldersToLoad: [PurgeFolder]
    private let dependenciesToLoad: [String]

    // Track generic calls
    private(set) var didDeleteAllFolders = false
    private(set) var deletedFolders: [PurgeFolder] = []
    private(set) var openedFolderURL: URL?
    private(set) var receivedProgressHandler: PurgeProgressHandler?

    // Track feature-specific calls for backward compatibility
    private(set) var didDeleteAllDerivedData = false
    private(set) var didDeleteAllPackages = false

    // Track dependency finding
    private(set) var didFindDependencies = false
    private(set) var searchedPath: String?

    init(throwError: Bool = false, throwDependencyError: Bool = false, foldersToLoad: [PurgeFolder] = [], dependenciesToLoad: [String] = []) {
        self.throwError = throwError
        self.throwDependencyError = throwDependencyError
        self.foldersToLoad = foldersToLoad
        self.dependenciesToLoad = dependenciesToLoad
    }

    func loadFolders() -> [PurgeFolder] {
        return foldersToLoad
    }

    func deleteAllFolders(progressHandler: PurgeProgressHandler?) throws {
        if throwError {
            throw NSError(domain: "TestError", code: 1)
        }

        receivedProgressHandler = progressHandler
        didDeleteAllFolders = true
        // Set feature-specific flags for backward compatibility with integration tests
        didDeleteAllDerivedData = true
        didDeleteAllPackages = true

        for (index, folder) in foldersToLoad.enumerated() {
            progressHandler?.updateProgress(current: index + 1, total: foldersToLoad.count, message: "Deleting \(folder.name)...")
        }
    }

    func deleteAllDerivedData(progressHandler: PurgeProgressHandler?) throws {
        if throwError {
            throw NSError(domain: "TestError", code: 1)
        }

        receivedProgressHandler = progressHandler
        didDeleteAllDerivedData = true
        didDeleteAllFolders = true

        for (index, folder) in foldersToLoad.enumerated() {
            progressHandler?.updateProgress(current: index + 1, total: foldersToLoad.count, message: "Deleting \(folder.name)...")
        }
    }

    func deleteAllPackages(progressHandler: PurgeProgressHandler?) throws {
        if throwError {
            throw NSError(domain: "TestError", code: 1)
        }

        receivedProgressHandler = progressHandler
        didDeleteAllPackages = true
        didDeleteAllFolders = true

        for (index, folder) in foldersToLoad.enumerated() {
            progressHandler?.updateProgress(current: index + 1, total: foldersToLoad.count, message: "Deleting \(folder.name)...")
        }
    }

    func deleteFolders(_ folders: [PurgeFolder], progressHandler: PurgeProgressHandler?) throws {
        if throwError {
            throw NSError(domain: "TestError", code: 1)
        }

        receivedProgressHandler = progressHandler
        deletedFolders.append(contentsOf: folders)

        for (index, folder) in folders.enumerated() {
            progressHandler?.updateProgress(current: index + 1, total: folders.count, message: "Deleting \(folder.name)...")
        }
    }

    func openFolder(at url: URL) throws {
        if throwError {
            throw NSError(domain: "TestError", code: 1)
        }

        openedFolderURL = url
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
}
