//
//  PackageCacheService.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Foundation

// Type alias for progress handler to maintain API compatibility
public typealias PackageCacheProgressHandler = PurgeProgressHandler

// PackageCacheService now inherits from PurgeService
public protocol PackageCacheService: PurgeService {
    func deleteAllPackages(progressHandler: PackageCacheProgressHandler?) throws
}

public extension PackageCacheService {
    func deleteAllPackages() throws {
        try deleteAllPackages(progressHandler: nil)
    }

    // Default implementation of PurgeService.deleteAllFolders using deleteAllPackages
    func deleteAllFolders(progressHandler: PurgeProgressHandler?) throws {
        try deleteAllPackages(progressHandler: progressHandler)
    }
}
