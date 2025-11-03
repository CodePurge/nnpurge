//
//  MockDerivedDataService.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 10/26/25.
//

import Foundation
import CodePurgeKit
@testable import nnpurge

final class MockDerivedDataService: @unchecked Sendable, DerivedDataService {
    private let throwError: Bool
    private let foldersToLoad: [PurgeFolder]

    private(set) var didDeleteAllDerivedData = false
    private(set) var deletedFolders: [PurgeFolder] = []
    private(set) var openedFolderURL: URL?
    private(set) var receivedProgressHandler: DerivedDataProgressHandler?

    init(throwError: Bool = false, foldersToLoad: [PurgeFolder] = []) {
        self.throwError = throwError
        self.foldersToLoad = foldersToLoad
    }

    func loadFolders() -> [PurgeFolder] {
        return foldersToLoad
    }

    func deleteAllDerivedData(progressHandler: DerivedDataProgressHandler?) throws {
        if throwError {
            throw NSError(domain: "TestError", code: 1)
        }

        receivedProgressHandler = progressHandler
        didDeleteAllDerivedData = true

        for folder in foldersToLoad {
            progressHandler?.didDeleteFolder(folder)
        }
    }

    func deleteFolders(_ folders: [PurgeFolder], progressHandler: DerivedDataProgressHandler?) throws {
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
