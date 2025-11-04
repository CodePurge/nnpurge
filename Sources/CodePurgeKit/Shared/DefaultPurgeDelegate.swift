//
//  DefaultPurgeDelegate.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Files
import Foundation
#if canImport(AppKit)
import AppKit
#endif

/// Default implementation of PurgeDelegate using FileManager and Files package
struct DefaultPurgeDelegate: PurgeDelegate {
    func deleteFolder(_ folder: PurgeFolder) throws {
        try FileManager.default.trashItem(at: folder.url, resultingItemURL: nil)
    }

    func loadFolders(path: String) throws -> [PurgeFolder] {
        return try Folder(path: path).subfolders.map({ .init(folder: $0) })
    }

    func openFolder(at url: URL) throws {
        #if canImport(AppKit)
        NSWorkspace.shared.open(url)
        #else
        throw NSError(
            domain: "DefaultPurgeDelegate",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Opening folders is only supported on macOS"]
        )
        #endif
    }
}

/// Extension to create PurgeFolder from Files.Folder
private extension PurgeFolder {
    init(folder: Folder) {
        self.init(
            url: folder.url,
            name: folder.name,
            path: folder.path,
            size: 0,
            modificationDate: folder.modificationDate,
            creationDate: folder.creationDate
        )
    }
}
