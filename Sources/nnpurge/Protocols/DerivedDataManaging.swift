//
//  DerivedDataManaging.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import Files

protocol DerivedDataManaging {
    func loadDerivedDataFolders() throws -> [Folder]
    func moveFoldersToTrash(_ folders: [Folder]) throws
}
