//
//  DerivedDataManager.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 10/26/25.
//

import Foundation

public struct DerivedDataManager {
    private let path: String
    private let loader: any PurgeFolderLoader
    private let delegate: any DerivedDataDelegate
    private let xcodeChecker: any XcodeStatusChecker
    private let xcodeTerminator: any XcodeTerminator

    init(path: String, loader: any PurgeFolderLoader, delegate: any DerivedDataDelegate, xcodeChecker: any XcodeStatusChecker, xcodeTerminator: any XcodeTerminator) {
        self.path = path
        self.loader = loader
        self.delegate = delegate
        self.xcodeChecker = xcodeChecker
        self.xcodeTerminator = xcodeTerminator
    }
}


// MARK: - Init
public extension DerivedDataManager {
    init(path: String) {
        self.init(path: path, loader: DefaultPurgeFolderLoader(), delegate: DefaultDerivedDataDelegate(), xcodeChecker: DefaultXcodeStatusChecker(), xcodeTerminator: DefaultXcodeTerminator())
    }
}


// MARK: - DerivedDataService
extension DerivedDataManager: DerivedDataService {
    public func loadFolders() throws -> [DerivedDataFolder] {
        return try loader.loadPurgeFolders(at: path).map({ .init(folder: $0) })
    }

    public func deleteFolders(_ folders: [DerivedDataFolder], force: Bool, progressHandler: (any PurgeProgressHandler)?) throws {
        if !force {
            guard !xcodeChecker.isXcodeRunning() else {
                throw DerivedDataError.xcodeIsRunning
            }
        }

        let total = folders.count

        for (index, folder) in folders.enumerated() {
            try delegate.deleteFolder(folder)
            progressHandler?.updateProgress(current: index + 1, total: total, message: "Moving \(folder.name) to trash...")
        }

        progressHandler?.complete(message: "✅ Derived Data moved to trash.")
    }

    public func closeXcodeAndVerify(timeout: TimeInterval = 10.0) throws {
        guard xcodeTerminator.terminateXcode() else {
            throw DerivedDataError.xcodeFailedToClose
        }

        let pollInterval = 0.5
        var elapsed = 0.0

        while xcodeChecker.isXcodeRunning() && elapsed < timeout {
            Thread.sleep(forTimeInterval: pollInterval)
            elapsed += pollInterval
        }

        if xcodeChecker.isXcodeRunning() {
            throw DerivedDataError.xcodeFailedToClose
        }
    }
}


// MARK: - Dependencies
protocol DerivedDataDelegate {
    func deleteFolder(_ folder: DerivedDataFolder) throws
}

protocol XcodeStatusChecker {
    func isXcodeRunning() -> Bool
}

protocol XcodeTerminator {
    func terminateXcode() -> Bool
}

public enum DerivedDataError: Error {
    case xcodeIsRunning
    case xcodeFailedToClose
}


// MARK: - Extension Dependencies
private extension DerivedDataFolder {
    init(folder: any PurgeFolder) {
        self.init(url: folder.url, name: folder.name, path: folder.path, creationDate: folder.creationDate, modificationDate: folder.modificationDate)
    }
}
