//
//  ArchiveManager.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 11/4/25.
//

import Foundation

public struct ArchiveManager: ArchiveService {
    private let manager: GenericPurgeManager

    init(purgeDelegate: any PurgeDelegate) {
        let path = "~/Library/Developer/Xcode/Archives"
        let config = PurgeConfiguration(path: path, expandPath: true)
        self.manager = GenericPurgeManager(configuration: config, delegate: purgeDelegate)
    }
}


// MARK: - Init
public extension ArchiveManager {
    init() {
        self.init(purgeDelegate: DefaultPurgeDelegate())
    }
}


// MARK: - Actions
public extension ArchiveManager {
    func loadFolders() throws -> [PurgeFolder] {
        try manager.loadFolders()
    }

    func deleteAllArchives(progressHandler: PurgeProgressHandler?) throws {
        try manager.deleteAllFolders(progressHandler: progressHandler)
    }

    func deleteFolders(_ folders: [PurgeFolder], progressHandler: PurgeProgressHandler?) throws {
        try manager.deleteFolders(folders, progressHandler: progressHandler)
    }

    func openFolder(at url: URL) throws {
        try manager.openFolder(at: url)
    }
}
