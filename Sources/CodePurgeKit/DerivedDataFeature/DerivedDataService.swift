//
//  DerivedDataService.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 10/26/25.
//

import Foundation

public protocol DerivedDataService {
    func deleteAllDerivedData() throws
    func loadFolders() throws -> [PurgeFolder]
    func deleteFolders(_ folders: [PurgeFolder]) throws
    func openFolder(at url: URL) throws
}
