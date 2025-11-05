//
//  MockPurgeService.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Foundation
import CodePurgeKit
@testable import nnpurge

final class MockPurgeService: @unchecked Sendable, DerivedDataService {
    private let throwError: Bool
    private let derivedDataFoldersToLoad: [DerivedDataFolder]

    private(set) var didDeleteAllDerivedData = false
    private(set) var deletedDerivedDataFolders: [DerivedDataFolder] = []
    private(set) var receivedProgressHandler: PurgeProgressHandler?

    init(
        throwError: Bool = false,
        derivedDataFoldersToLoad: [DerivedDataFolder] = []
    ) {
        self.throwError = throwError
        self.derivedDataFoldersToLoad = derivedDataFoldersToLoad
    }

    func loadFolders() throws -> [DerivedDataFolder] {
        if throwError {
            throw NSError(domain: "TestError", code: 1)
        }

        return derivedDataFoldersToLoad
    }

    func deleteDerivedData(_ folders: [DerivedDataFolder], progressHandler: (any PurgeProgressHandler)?) throws {
        if throwError {
            throw NSError(domain: "TestError", code: 1)
        }

        receivedProgressHandler = progressHandler
        didDeleteAllDerivedData = true
        deletedDerivedDataFolders.append(contentsOf: folders)

        for (index, folder) in folders.enumerated() {
            progressHandler?.updateProgress(current: index + 1, total: folders.count, message: "Deleting \(folder.name)...")
        }

        progressHandler?.complete(message: "✅ Derived Data moved to trash.")
    }
}
