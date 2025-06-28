//
//  PackageCacheManager.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import Files
import Foundation

/// Concrete implementation responsible for locating and deleting cached Swift Package repositories.
struct PackageCacheManager: PackageCacheDelegate {
    /// Object used for enumerating folders at the cache path.
    let folderLoader: FolderLoader

    /// File manager capable of moving items to the trash.
    let fileManager: FileTrasher

    /// Creates a manager with injectable dependencies for testing or customisation.
    init(folderLoader: FolderLoader = DefaultFolderLoader(), fileManager: FileTrasher = FileManager.default) {
        self.folderLoader = folderLoader
        self.fileManager = fileManager
    }

    /// Loads all package repository folders located in the global Swift Package cache.
    func loadPackageFolders() throws -> [Folder] {
        let path = "~/Library/Caches/org.swift.swiftpm/repositories"
        let expandedPath = NSString(string: path).expandingTildeInPath
        return try folderLoader.subfolders(at: expandedPath)
    }

    /// Moves the provided folders to the user's Trash.
    func moveFoldersToTrash(_ folders: [Folder]) throws {
        for folder in folders {
            print("Moving \(folder.name) to Trash")
            try fileManager.trashItem(at: folder.url, resultingItemURL: nil)
            print("\(folder.name) successfully moved to Trash")
        }
    }
}
