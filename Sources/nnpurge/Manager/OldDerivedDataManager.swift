//
//  OldDerivedDataManager.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import Files
import Foundation

struct OldDerivedDataManager {
    let userDefaults: DerivedDataStore
    let folderLoader: FolderLoader
    let fileManager: FileTrasher
    
    init(userDefaults: DerivedDataStore, folderLoader: FolderLoader = DefaultFolderLoader(), fileManager: FileTrasher = FileManager.default) {
        self.userDefaults = userDefaults
        self.folderLoader = folderLoader
        self.fileManager = fileManager
    }
}


// MARK: - DerivedDataDelegate
extension OldDerivedDataManager: DerivedDataDelegate {
    func loadDerivedDataFolders() throws -> [Folder] {
        let defaultPath = "~/Library/Developer/Xcode/DerivedData"
        let savedPath = userDefaults.string(forKey: "derivedDataPath") ?? defaultPath
        let expandedPath = NSString(string: savedPath).expandingTildeInPath
        return try folderLoader.subfolders(at: expandedPath)
    }

    func moveFoldersToTrash(_ folders: [Folder]) throws {
        for folder in folders {
            print("Moving \(folder.name) to Trash")
            try fileManager.trashItem(at: folder.url, resultingItemURL: nil)
            print("\(folder.name) successfully moved to Trash")
        }
    }
}
