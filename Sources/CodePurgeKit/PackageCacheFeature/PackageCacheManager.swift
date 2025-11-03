//
//  PackageCacheManager.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Foundation

public struct PackageCacheManager: PackageCacheService {
    private let delegate: any PackageCacheDelegate

    init(delegate: any PackageCacheDelegate) {
        self.delegate = delegate
    }
}


// MARK: - Init
public extension PackageCacheManager {
    init() {
        self.init(delegate: DefaultPackageCacheDelegate())
    }
}


// MARK: - Actions
public extension PackageCacheManager {
    func loadFolders() throws -> [PurgeFolder] {
        let path = "~/Library/Caches/org.swift.swiftpm/repositories"
        let expandedPath = NSString(string: path).expandingTildeInPath

        return try delegate.loadFolders(path: expandedPath)
    }

    func deleteAllPackages(progressHandler: PackageCacheProgressHandler?) throws {
        let allFolders = try loadFolders()

        try deleteFolders(allFolders, progressHandler: progressHandler)
    }

    func deleteFolders(_ folders: [PurgeFolder], progressHandler: PackageCacheProgressHandler?) throws {
        for folder in folders {
            try delegate.deleteFolder(folder)
            progressHandler?.didDeleteFolder(folder)
        }
    }

    func openFolder(at url: URL) throws {
        try delegate.openFolder(at: url)
    }
}


// MARK: - Dependencies
public protocol PackageCacheProgressHandler {
    func didDeleteFolder(_ folder: PurgeFolder)
}

protocol PackageCacheDelegate {
    func deleteFolder(_ folder: PurgeFolder) throws
    func loadFolders(path: String) throws -> [PurgeFolder]
    func openFolder(at url: URL) throws
}
