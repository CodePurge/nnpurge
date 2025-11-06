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
    private let xcodeChecker: any XcodeStatusChecker
    private let xcodeTerminator: any XcodeTerminator
    private let deletionHelper: PurgableItemDeletionHelper

    init(loader: any PurgeFolderLoader, delegate: any PackageCacheDelegate, fileSystemDelegate: any FileSystemDelegate, xcodeChecker: any XcodeStatusChecker, xcodeTerminator: any XcodeTerminator) {
        self.loader = loader
        self.delegate = delegate
        self.fileSystemDelegate = fileSystemDelegate
        self.xcodeChecker = xcodeChecker
        self.xcodeTerminator = xcodeTerminator
        self.deletionHelper = PurgableItemDeletionHelper(deleter: delegate, xcodeChecker: xcodeChecker)
        self.path = NSString(string: "~/Library/Caches/org.swift.swiftpm/repositories").expandingTildeInPath
    }
}


// MARK: - Init
public extension PackageCacheManager {
    init() {
        self.init(loader: DefaultPurgeFolderLoader(), delegate: DefaultPackageCacheDelegate(), fileSystemDelegate: DefaultFileSystemDelegate(), xcodeChecker: DefaultXcodeStatusChecker(), xcodeTerminator: DefaultXcodeTerminator())
    }
}


// MARK: - Actions
extension PackageCacheManager: PackageCacheService {
    public func loadFolders() throws -> [PackageCacheFolder] {
        return try loader.loadPurgeFolders(at: path).compactMap({ .init(folder: $0) })
    }
    
    public func deleteFolders(_ folders: [PackageCacheFolder], force: Bool, progressHandler: (any PurgeProgressHandler)?) throws {
        try deletionHelper.deleteItems(
            folders,
            force: force,
            progressHandler: progressHandler,
            completionMessage: "✅ Package Repositories moved to trash.",
            xcodeRunningError: PackageCacheError.xcodeIsRunning
        )
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

    public func closeXcodeAndVerify(timeout: TimeInterval = 10.0) throws {
        guard xcodeTerminator.terminateXcode() else {
            throw PackageCacheError.xcodeFailedToClose
        }

        let pollInterval = 0.5
        var elapsed = 0.0

        while xcodeChecker.isXcodeRunning() && elapsed < timeout {
            Thread.sleep(forTimeInterval: pollInterval)
            elapsed += pollInterval
        }

        if xcodeChecker.isXcodeRunning() {
            throw PackageCacheError.xcodeFailedToClose
        }
    }
}


// MARK: - Dependencies
protocol PackageCacheDelegate: PurgableItemDeleter {
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
    init?(folder: any PurgeFolder) {
        guard let (name, branchId) = folder.parseNameAndBranchId() else {
            return nil
        }
        
        self.init(
            url: folder.url,
            name: name,
            path: folder.path,
            creationDate: folder.creationDate,
            modificationDate: folder.modificationDate,
            branchId: branchId,
            lastFetchedDate: folder.getFilePath(named: "FETCH_HEAD")
        )
    }
}

private extension PurgeFolder {
    func parseNameAndBranchId() -> (name: String, branchId: String)? {
        let components = name.split(separator: "-").map(String.init)
        
        guard components.count > 1 else {
            return nil
        }
        
        let branchId = components.last!
        let combinedName = components.dropLast().joined(separator: "-")
        
        return (combinedName, branchId)
    }
}
