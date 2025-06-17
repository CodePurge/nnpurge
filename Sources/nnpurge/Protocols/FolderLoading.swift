//
//  FolderLoading.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import Files

protocol FolderLoading {
    func subfolders(at path: String) throws -> [Folder]
}

struct FolderLoader: FolderLoading {
    func subfolders(at path: String) throws -> [Folder] {
        try Folder(path: path).subfolders.map { $0 }
    }
}
