//
//  PurgeService.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Foundation

public protocol PurgeService {
    func openFolder(at url: URL) throws
    func loadFolders() throws -> [PurgeFolder]
    func deleteAllFolders(progressHandler: PurgeProgressHandler?) throws
    func deleteFolders(_ folders: [PurgeFolder], progressHandler: PurgeProgressHandler?) throws
}

public extension PurgeService {
    func deleteAllFolders() throws {
        try deleteAllFolders(progressHandler: nil)
    }

    func deleteFolders(_ folders: [PurgeFolder]) throws {
        try deleteFolders(folders, progressHandler: nil)
    }
}

public protocol PurgeProgressHandler {
    func didDeleteFolder(_ folder: PurgeFolder)
}
