//
//  PackageCacheService.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Foundation

public protocol PackageCacheService: PurgeService {
    func deleteAllPackages(progressHandler: PurgeProgressHandler?) throws
    func findDependencies(in path: String?) throws -> ProjectDependencies
}

public extension PackageCacheService {
    func deleteAllPackages() throws {
        try deleteAllPackages(progressHandler: nil)
    }

    func deleteAllFolders(progressHandler: PurgeProgressHandler?) throws {
        try deleteAllPackages(progressHandler: progressHandler)
    }
}
