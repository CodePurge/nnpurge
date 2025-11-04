//
//  PackageCacheService.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Foundation

public typealias PackageCacheProgressHandler = PurgeProgressHandler

public protocol PackageCacheService: PurgeService {
    func deleteAllPackages(progressHandler: PackageCacheProgressHandler?) throws
}

public extension PackageCacheService {
    func deleteAllPackages() throws {
        try deleteAllPackages(progressHandler: nil)
    }

    func deleteAllFolders(progressHandler: PurgeProgressHandler?) throws {
        try deleteAllPackages(progressHandler: progressHandler)
    }
}
