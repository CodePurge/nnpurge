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
    private let foldersToLoad: [PurgeFolder]

    // Track generic calls
    private(set) var didDeleteAllFolders = false
    private(set) var deletedFolders: [PurgeFolder] = []
    private(set) var openedFolderURL: URL?
    private(set) var receivedProgressHandler: PurgeProgressHandler?

    // Track feature-specific calls for backward compatibility
    private(set) var didDeleteAllDerivedData = false
    private(set) var didDeleteAllPackages = false

    init(throwError: Bool = false, foldersToLoad: [PurgeFolder] = []) {
        self.throwError = throwError
        self.foldersToLoad = foldersToLoad
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

        for folder in foldersToLoad {
            progressHandler?.didDeleteFolder(folder)
        }
    }

    func deleteAllDerivedData(progressHandler: DerivedDataProgressHandler?) throws {
        if throwError {
            throw NSError(domain: "TestError", code: 1)
        }

        receivedProgressHandler = progressHandler
        didDeleteAllDerivedData = true
        didDeleteAllFolders = true

        for folder in foldersToLoad {
            progressHandler?.didDeleteFolder(folder)
        }
    }

    func deleteAllPackages(progressHandler: PackageCacheProgressHandler?) throws {
        if throwError {
            throw NSError(domain: "TestError", code: 1)
        }

        receivedProgressHandler = progressHandler
        didDeleteAllPackages = true
        didDeleteAllFolders = true

        for folder in foldersToLoad {
            progressHandler?.didDeleteFolder(folder)
        }
    }

    func deleteFolders(_ folders: [PurgeFolder], progressHandler: PurgeProgressHandler?) throws {
        if throwError {
            throw NSError(domain: "TestError", code: 1)
        }

        receivedProgressHandler = progressHandler
        deletedFolders.append(contentsOf: folders)

        for folder in folders {
            progressHandler?.didDeleteFolder(folder)
        }
    }

    func openFolder(at url: URL) throws {
        if throwError {
            throw NSError(domain: "TestError", code: 1)
        }

        openedFolderURL = url
    }
}
