//
//  PackageCacheService.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Foundation

public protocol PackageCacheService {
    func loadFolders() throws -> [PurgeFolder]
    func deleteAllPackages(progressHandler: PackageCacheProgressHandler?) throws
    func deleteFolders(_ folders: [PurgeFolder], progressHandler: PackageCacheProgressHandler?) throws
    func openFolder(at url: URL) throws
}

public extension PackageCacheService {
    func deleteAllPackages() throws {
        try deleteAllPackages(progressHandler: nil)
    }

    func deleteFolders(_ folders: [PurgeFolder]) throws {
        try deleteFolders(folders, progressHandler: nil)
    }
}
