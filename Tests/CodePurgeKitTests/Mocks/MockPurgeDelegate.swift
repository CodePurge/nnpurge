//
//  MockPurgeDelegate.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Foundation
@testable import CodePurgeKit

final class MockPurgeDelegate: PurgeDelegate, @unchecked Sendable {
    private let throwError: Bool
    private let foldersToLoad: [OldPurgeFolder]

    private(set) var deletedFolders: [OldPurgeFolder] = []
    private(set) var openedURL: URL?

    init(throwError: Bool = false, foldersToLoad: [OldPurgeFolder] = []) {
        self.throwError = throwError
        self.foldersToLoad = foldersToLoad
    }

    func deleteFolder(_ folder: OldPurgeFolder) throws {
        if throwError {
            throw NSError(domain: "MockPurgeDelegate", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        }
        deletedFolders.append(folder)
    }

    func loadFolders(path: String) throws -> [OldPurgeFolder] {
        if throwError {
            throw NSError(domain: "MockPurgeDelegate", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        }
        return foldersToLoad
    }

    func openFolder(at url: URL) throws {
        if throwError {
            throw NSError(domain: "MockPurgeDelegate", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        }
        openedURL = url
    }
}
