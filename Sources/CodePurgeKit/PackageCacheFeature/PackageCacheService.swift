//
//  PackageCacheService.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Foundation

public protocol PackageCacheService {
    func loadFolders() throws -> [PackageCacheFolder]
    func findDependencies(in path: String?) throws -> ProjectDependencies
    func deleteFolders(_ folders: [PackageCacheFolder], force: Bool, progressHandler: (any PurgeProgressHandler)?) throws
    func closeXcodeAndVerify(timeout: TimeInterval) throws
}
