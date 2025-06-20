//
//  DerivedDataManager.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import Files
import Foundation

/// Concrete implementation responsible for locating and deleting derived data
/// folders on disk.
struct DerivedDataManager: DerivedDataDelegate {
    /// Storage used to persist the preferred DerivedData path.
    let userDefaults: DerivedDataStore

    /// Object used for enumerating folders at a given path.
    let folderLoader: FolderLoader

    /// File manager capable of moving items to the trash.
    let fileManager: FileTrasher

    /// Creates a manager with injectable dependencies for testing or
    /// customization.
    init(userDefaults: DerivedDataStore, folderLoader: FolderLoader = DefaultFolderLoader(), fileManager: FileTrasher = FileManager.default) {
        self.userDefaults = userDefaults
        self.folderLoader = folderLoader
        self.fileManager = fileManager
    }

    /// Loads all folders located in the configured DerivedData directory.
    func loadDerivedDataFolders() throws -> [Folder] {
        let defaultPath = "~/Library/Developer/Xcode/DerivedData"
        let savedPath = userDefaults.string(forKey: "derivedDataPath") ?? defaultPath
        let expandedPath = NSString(string: savedPath).expandingTildeInPath
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
