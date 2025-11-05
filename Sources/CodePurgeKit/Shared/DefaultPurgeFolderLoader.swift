//
//  DefaultPurgeFolderLoader.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/4/25.
//

import Files

struct DefaultPurgeFolderLoader: PurgeFolderLoader {
    func loadPurgeFolders(at path: String) throws -> [any PurgeFolder] {
        return try Folder(path: path).subfolders.map({ PurgeFolderContainer(folder: $0) })
    }
}
