//
//  PackageCacheManager.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Foundation

public struct PackageCacheManager: PackageCacheService {
    private let manager: GenericPurgeManager

    init(delegate: any PurgeDelegate) {
        let path = "~/Library/Caches/org.swift.swiftpm/repositories"
        let config = PurgeConfiguration(path: path, expandPath: true)
        self.manager = GenericPurgeManager(configuration: config, delegate: delegate)
    }
}


// MARK: - Init
public extension PackageCacheManager {
    init() {
        self.init(delegate: DefaultPurgeDelegate())
    }
}


// MARK: - Actions
public extension PackageCacheManager {
    func loadFolders() throws -> [PurgeFolder] {
        try manager.loadFolders()
    }

    func deleteAllPackages(progressHandler: PackageCacheProgressHandler?) throws {
        try manager.deleteAllFolders(progressHandler: progressHandler)
    }

    func deleteFolders(_ folders: [PurgeFolder], progressHandler: PackageCacheProgressHandler?) throws {
        try manager.deleteFolders(folders, progressHandler: progressHandler)
    }

    func openFolder(at url: URL) throws {
        try manager.openFolder(at: url)
    }
}


