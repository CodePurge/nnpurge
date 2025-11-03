//
//  MockDerivedDataDelegate.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Foundation
@testable import CodePurgeKit

final class MockDerivedDataDelegate: @unchecked Sendable, DerivedDataDelegate {
    private let throwError: Bool
    private let foldersToLoad: [PurgeFolder]

    private(set) var deletedFolders: [PurgeFolder] = []
    private(set) var loadFoldersCallCount = 0
    private(set) var lastPathLoaded: String?
    private(set) var openedFolderURL: URL?

    init(throwError: Bool = false, foldersToLoad: [PurgeFolder] = []) {
        self.throwError = throwError
        self.foldersToLoad = foldersToLoad
    }

    func deleteFolder(_ folder: PurgeFolder) throws {
        if throwError {
            throw NSError(domain: "TestError", code: 1)
        }

        deletedFolders.append(folder)
    }

    func loadFolders(path: String) throws -> [PurgeFolder] {
        loadFoldersCallCount += 1
        lastPathLoaded = path

        if throwError {
            throw NSError(domain: "TestError", code: 1)
        }

        return foldersToLoad
    }

    func openFolder(at url: URL) throws {
        if throwError {
            throw NSError(domain: "TestError", code: 1)
        }

        openedFolderURL = url
    }
}
