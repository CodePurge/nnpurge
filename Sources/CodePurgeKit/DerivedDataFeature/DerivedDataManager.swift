//
//  DerivedDataManager.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 10/26/25.
//

import Foundation

public struct DerivedDataManager: DerivedDataService {
    private let manager: GenericPurgeManager

    init(path: String, delegate: any PurgeDelegate) {
        let config = PurgeConfiguration(path: path, expandPath: false)
        self.manager = GenericPurgeManager(configuration: config, delegate: delegate)
    }
}


// MARK: - Init
public extension DerivedDataManager {
    init(path: String) {
        self.init(path: path, delegate: DefaultPurgeDelegate())
    }
}


// MARK: - Actions
public extension DerivedDataManager {
    func loadFolders() throws -> [OldPurgeFolder] {
        try manager.loadFolders()
    }

    func deleteAllDerivedData(progressHandler: PurgeProgressHandler?) throws {
        try manager.deleteAllFolders(progressHandler: progressHandler)
    }

    func deleteFolders(_ folders: [OldPurgeFolder], progressHandler: PurgeProgressHandler?) throws {
        try manager.deleteFolders(folders, progressHandler: progressHandler)

        // TODO: - save purge record?
    }

    func openFolder(at url: URL) throws {
        try manager.openFolder(at: url)
    }
}
