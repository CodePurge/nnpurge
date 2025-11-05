//
//  DerivedDataService.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 10/26/25.
//

import Foundation

public protocol DerivedDataService {
    func loadFolders() throws -> [DerivedDataFolder]
    func deleteFolders(_ folders: [DerivedDataFolder], force: Bool, progressHandler: (any PurgeProgressHandler)?) throws
}
