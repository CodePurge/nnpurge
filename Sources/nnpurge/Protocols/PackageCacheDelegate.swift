//
//  PackageCacheDelegate.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import Files

/// Interface for interacting with the global Swift Package cache.
protocol PackageCacheDelegate {
    /// Loads all cached package repository folders.
    func loadPackageFolders() throws -> [Folder]

    /// Moves the specified folders to the trash.
    func moveFoldersToTrash(_ folders: [Folder]) throws
}
