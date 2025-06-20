//
//  FolderLoader.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import Files

/// Protocol for loading folders from disk.
protocol FolderLoader {
    /// Returns all subfolders located at the given path.
    func subfolders(at path: String) throws -> [Folder]
}

/// Default implementation that uses the `Files` package.
struct DefaultFolderLoader: FolderLoader {
    func subfolders(at path: String) throws -> [Folder] {
        try Folder(path: path).subfolders.map { $0 }
    }
}
