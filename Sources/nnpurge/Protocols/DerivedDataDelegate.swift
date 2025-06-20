//
//  DerivedDataDelegate.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import Files

/// Interface for interacting with Xcode's DerivedData folder.
protocol DerivedDataDelegate {
    /// Loads all derived data folders.
    func loadDerivedDataFolders() throws -> [Folder]

    /// Moves the specified folders to the trash.
    func moveFoldersToTrash(_ folders: [Folder]) throws
}
