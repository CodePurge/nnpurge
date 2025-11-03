//
//  DefaultDerivedDataDelegate.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Files
import Foundation

struct DefaultDerivedDataDelegate: DerivedDataDelegate {
    func deleteFolder(_ folder: PurgeFolder) throws {
        try FileManager.default.trashItem(at: folder.url, resultingItemURL: nil)
    }
    
    func loadFolders(path: String) throws -> [PurgeFolder] {
        return try Folder(path: path).subfolders.map({ .init(folder: $0) })
    }
}


// MARK: - Extension Dependencies
private extension PurgeFolder {
    init(folder: Folder) {
        // TODO: - should size be calculated here?
        self.init(url: folder.url, name: folder.name, path: folder.path, size: 0)
    }
}
