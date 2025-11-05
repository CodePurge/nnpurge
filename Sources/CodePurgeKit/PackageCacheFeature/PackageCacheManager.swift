//
//  PackageCacheManager.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Foundation

public struct PackageCacheManager {
    private let path: String
    private let loader: any PurgeFolderLoader
    private let delegate: any PackageCacheDelegate
    private let fileSystemDelegate: any FileSystemDelegate

    init(loader: any PurgeFolderLoader, delegate: any PackageCacheDelegate, fileSystemDelegate: any FileSystemDelegate) {
        self.loader = loader
        self.delegate = delegate
        self.fileSystemDelegate = fileSystemDelegate
        self.path = NSString(string: "~/Library/Caches/org.swift.swiftpm/repositories").expandingTildeInPath
    }
}


// MARK: - Init
public extension PackageCacheManager {
    init() {
        self.init(loader: DefaultPurgeFolderLoader(), delegate: DefaultPackageCacheDelegate(), fileSystemDelegate: DefaultFileSystemDelegate())
    }
}


// MARK: - Actions
extension PackageCacheManager: PackageCacheService {
    public func loadFolders() throws -> [PackageCacheFolder] {
        return try loader.loadPurgeFolders(at: path).map({ .init(folder: $0) })
    }
    
    public func deleteFolders(_ folders: [PackageCacheFolder], progressHandler: (any PurgeProgressHandler)?) throws {
        let total = folders.count
        
        for (index, folder) in folders.enumerated() {
            try delegate.deleteFolder(folder)
            progressHandler?.updateProgress(current: index + 1, total: total, message: "Moving \(folder.name) to trash...")
        }
        
        progressHandler?.complete(message: "✅ Package Repositories moved to trash.")
    }

    public func findDependencies(in path: String?) throws -> ProjectDependencies {
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
protocol PackageCacheDelegate {
    func deleteFolder(_ folder: PackageCacheFolder) throws
}

protocol FileSystemDelegate {
    var currentDirectoryPath: String { get }
    func fileExists(atPath path: String) -> Bool
    func appendingPathComponent(_ path: String, _ component: String) -> String
    func readData(atPath path: String) throws -> Data
}


// MARK: - Extension Dependencies
private extension PackageCacheFolder {
    init(folder: any PurgeFolder) {
        self.init(
            url: folder.url,
            name: folder.name,
            path: folder.path,
            creationDate: folder.creationDate,
            modificationDate: folder.modificationDate,
            branchId: "", // TODO: -
            lastFetchedDate: nil // TODO: -
        )
    }
}
