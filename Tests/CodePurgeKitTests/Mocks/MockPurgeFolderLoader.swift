//
//  MockPurgeFolderLoader.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 11/4/25.
//

import Foundation
@testable import CodePurgeKit

final class MockPurgeFolderLoader: PurgeFolderLoader, @unchecked Sendable {
    private let throwError: Bool
    private let foldersToLoad: [any PurgeFolder]

    private(set) var loadedPath: String?

    init(throwError: Bool = false, foldersToLoad: [any PurgeFolder] = []) {
        self.throwError = throwError
        self.foldersToLoad = foldersToLoad
    }

    func loadPurgeFolders(at path: String) throws -> [any PurgeFolder] {
        loadedPath = path
        if throwError {
            throw NSError(domain: "MockPurgeFolderLoader", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        }
        return foldersToLoad
    }
}
