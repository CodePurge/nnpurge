//
//  PackageCacheManager.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Foundation

public struct PackageCacheManager: PackageCacheService {
    private let manager: GenericPurgeManager
    private let fileSystemDelegate: any FileSystemDelegate

    init(purgeDelegate: any PurgeDelegate, fileSystemDelegate: any FileSystemDelegate) {
        let path = "~/Library/Caches/org.swift.swiftpm/repositories"
        let config = PurgeConfiguration(path: path, expandPath: true)
        self.manager = GenericPurgeManager(configuration: config, delegate: purgeDelegate)
        self.fileSystemDelegate = fileSystemDelegate
    }
}


// MARK: - Init
public extension PackageCacheManager {
    init() {
        self.init(purgeDelegate: DefaultPurgeDelegate(), fileSystemDelegate: DefaultFileSystemDelegate())
    }
}


// MARK: - Actions
public extension PackageCacheManager {
    func loadFolders() throws -> [OldPurgeFolder] {
        try manager.loadFolders()
    }

    func deleteAllPackages(progressHandler: PurgeProgressHandler?) throws {
        try manager.deleteAllFolders(progressHandler: progressHandler)
    }

    func deleteFolders(_ folders: [OldPurgeFolder], progressHandler: PurgeProgressHandler?) throws {
        try manager.deleteFolders(folders, progressHandler: progressHandler)
    }

    func openFolder(at url: URL) throws {
        try manager.openFolder(at: url)
    }

    func findDependencies(in path: String?) throws -> ProjectDependencies {
        let searchPath = path ?? fileSystemDelegate.currentDirectoryPath
        let resolvedPath = fileSystemDelegate.appendingPathComponent(searchPath, "Package.resolved")

        guard fileSystemDelegate.fileExists(atPath: resolvedPath) else {
            throw PackageCacheError.packageResolvedNotFound(path: searchPath)
        }

        let data = try fileSystemDelegate.readData(atPath: resolvedPath)
        let decoder = JSONDecoder()

        return try decoder.decode(ProjectDependencies.self, from: data)
    }
}


// MARK: - Dependencies
protocol FileSystemDelegate {
    var currentDirectoryPath: String { get }
    func fileExists(atPath path: String) -> Bool
    func appendingPathComponent(_ path: String, _ component: String) -> String
    func readData(atPath path: String) throws -> Data
}
