//
//  DerivedDataService.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 10/26/25.
//

import Foundation

public protocol DerivedDataService {
    func loadFolders() throws -> [PurgeFolder]
    func deleteAllDerivedData(progressHandler: DerivedDataProgressHandler?) throws
    func deleteFolders(_ folders: [PurgeFolder], progressHandler: DerivedDataProgressHandler?) throws
    func openFolder(at url: URL) throws
}

public extension DerivedDataService {
    func deleteAllDerivedData() throws {
        try deleteAllDerivedData(progressHandler: nil)
    }

    func deleteFolders(_ folders: [PurgeFolder]) throws {
        try deleteFolders(folders, progressHandler: nil)
    }
}
