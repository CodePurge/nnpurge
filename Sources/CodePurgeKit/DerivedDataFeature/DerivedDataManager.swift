//
//  DerivedDataManager.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 10/26/25.
//

import Foundation

public struct DerivedDataManager: DerivedDataService {
    private let path: String
    private let delegate: DerivedDataDelegate

    init(path: String, delegate: DerivedDataDelegate) {
        self.path = path
        self.delegate = delegate
    }
}


// MARK: - Init
public extension DerivedDataManager {
    init(path: String) {
        self.init(path: path, delegate: DefaultDerivedDataDelegate())
    }
}


// MARK: - Actions
public extension DerivedDataManager {
    func loadFolders() throws -> [PurgeFolder] {
        return try delegate.loadFolders(path: path)
    }

    func deleteAllDerivedData() throws {
        let allFolders = try loadFolders()

        try deleteFolders(allFolders)
    }

    func deleteFolders(_ folders: [PurgeFolder]) throws {
        for folder in folders {
            try delegate.deleteFolder(folder)
            // TODO: - update progress?
        }

        // TODO: - save purge record?
    }

    func openFolder(at url: URL) throws {
        try delegate.openFolder(at: url)
    }
}


// MARK: - Dependencies
protocol DerivedDataDelegate {
    func deleteFolder(_ folder: PurgeFolder) throws
    func loadFolders(path: String) throws -> [PurgeFolder]
    func openFolder(at url: URL) throws
}
