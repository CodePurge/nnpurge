//
//  PurgeFolderLoader.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/4/25.
//

protocol PurgeFolderLoader {
    func loadPurgeFolders(at path: String) throws -> [any PurgeFolder]
}
