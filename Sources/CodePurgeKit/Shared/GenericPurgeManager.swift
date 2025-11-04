//
//  GenericPurgeManager.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Foundation

/// Configuration for purge operations
public struct PurgeConfiguration {
    public let path: String
    public let expandPath: Bool

    public init(path: String, expandPath: Bool = true) {
        self.path = path
        self.expandPath = expandPath
    }
}

/// Generic manager for purge operations that can be configured for different purge types
public struct GenericPurgeManager: PurgeService {
    private let configuration: PurgeConfiguration
    private let delegate: any PurgeDelegate

    init(configuration: PurgeConfiguration, delegate: any PurgeDelegate) {
        self.configuration = configuration
        self.delegate = delegate
    }

    public func loadFolders() throws -> [PurgeFolder] {
        let path = configuration.expandPath
            ? NSString(string: configuration.path).expandingTildeInPath
            : configuration.path
        return try delegate.loadFolders(path: path)
    }

    public func deleteAllFolders(progressHandler: PurgeProgressHandler?) throws {
        let allFolders = try loadFolders()
        try deleteFolders(allFolders, progressHandler: progressHandler)
    }

    public func deleteFolders(_ folders: [PurgeFolder], progressHandler: PurgeProgressHandler?) throws {
        for folder in folders {
            try delegate.deleteFolder(folder)
            progressHandler?.didDeleteFolder(folder)
        }
    }

    public func openFolder(at url: URL) throws {
        try delegate.openFolder(at: url)
    }
}

/// Internal delegate protocol for file system operations
protocol PurgeDelegate {
    func deleteFolder(_ folder: PurgeFolder) throws
    func loadFolders(path: String) throws -> [PurgeFolder]
    func openFolder(at url: URL) throws
}
