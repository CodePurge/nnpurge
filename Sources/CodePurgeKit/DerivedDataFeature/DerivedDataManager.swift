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

    init(path: String, loader: any PurgeFolderLoader, delegate: any DerivedDataDelegate, xcodeChecker: any XcodeStatusChecker) {
        self.path = path
        self.loader = loader
        self.delegate = delegate
        self.xcodeChecker = xcodeChecker
    }
}


// MARK: - Init
public extension DerivedDataManager {
    init(path: String) {
        self.init(path: path, loader: DefaultPurgeFolderLoader(), delegate: DefaultDerivedDataDelegate(), xcodeChecker: DefaultXcodeStatusChecker())
    }
}


// MARK: - DerivedDataService
extension DerivedDataManager: DerivedDataService {
    public func loadFolders() throws -> [DerivedDataFolder] {
        return try loader.loadPurgeFolders(at: path).map({ .init(folder: $0) })
    }
    
    public func deleteDerivedData(_ folders: [DerivedDataFolder], progressHandler: (any PurgeProgressHandler)?) throws {
        guard !xcodeChecker.isXcodeRunning() else {
            throw DerivedDataError.xcodeIsRunning
        }

        let total = folders.count

        for (index, folder) in folders.enumerated() {
            try delegate.deleteFolder(folder)
//            print("should delete \(folder.name)")
            progressHandler?.updateProgress(current: index + 1, total: total, message: "Moving \(folder.name) to trash...")
        }

        progressHandler?.complete(message: "✅ Derived Data moved to trash.")
    }
}


// MARK: - Dependencies
protocol DerivedDataDelegate {
    func deleteFolder(_ folder: DerivedDataFolder) throws
}

protocol XcodeStatusChecker {
    func isXcodeRunning() -> Bool
}

enum DerivedDataError: Error {
    case xcodeIsRunning
}


// MARK: - Extension Dependencies
private extension DerivedDataFolder {
    init(folder: any PurgeFolder) {
        self.init(url: folder.url, name: folder.name, path: folder.path, creationDate: folder.creationDate, modificationDate: folder.modificationDate)
    }
}
