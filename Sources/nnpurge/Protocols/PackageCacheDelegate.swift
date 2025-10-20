//
//  PackageCacheDelegate.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import Files

protocol PackageCacheDelegate {
    func loadPackageFolders() throws -> [Folder]
    func moveFoldersToTrash(_ folders: [Folder]) throws
}
