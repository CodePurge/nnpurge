//
//  DerivedDataService.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 10/26/25.
//

public protocol DerivedDataService {
    func deleteAllDerivedData() throws
    func loadFolders() throws -> [PurgeFolder]
    func deleteFolders(_ folders: [PurgeFolder]) throws
}
