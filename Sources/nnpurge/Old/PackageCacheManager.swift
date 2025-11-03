////
////  PackageCacheManager.swift
////  nnpurge
////
////  Created by Nikolai Nobadi on 6/17/25.
////
//
//import Files
//import Foundation
//
//struct PackageCacheManager {
//    let folderLoader: FolderLoader
//    let fileManager: FileTrasher
//    
//    init(folderLoader: FolderLoader = DefaultFolderLoader(), fileManager: FileTrasher = FileManager.default) {
//        self.folderLoader = folderLoader
//        self.fileManager = fileManager
//    }
//}
//
//
//// MARK: - PackageCacheDelegate
//extension PackageCacheManager: PackageCacheDelegate {
//    func loadPackageFolders() throws -> [Folder] {
//        let path = "~/Library/Caches/org.swift.swiftpm/repositories"
//        let expandedPath = NSString(string: path).expandingTildeInPath
//        return try folderLoader.subfolders(at: expandedPath)
//    }
//
//    func moveFoldersToTrash(_ folders: [Folder]) throws {
//        for folder in folders {
//            print("Moving \(folder.name) to Trash")
//            try fileManager.trashItem(at: folder.url, resultingItemURL: nil)
//            print("\(folder.name) successfully moved to Trash")
//        }
//    }
//}
