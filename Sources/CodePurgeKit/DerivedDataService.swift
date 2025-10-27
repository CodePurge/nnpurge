//
//  DerivedDataService.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 10/26/25.
//

public protocol DerivedDataService {
    func loadFolders() -> [PurgeFolder]
    func deleteAllDerivedData() throws
    func deleteFolders(_ folders: [PurgeFolder]) throws
}
