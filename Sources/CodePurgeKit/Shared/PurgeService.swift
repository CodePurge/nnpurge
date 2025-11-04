//
//  PurgeService.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Foundation

/// Generic protocol for purge services that manage folder deletion operations
public protocol PurgeService {
    /// Loads all folders available for purging
    func loadFolders() throws -> [PurgeFolder]

    /// Deletes all folders with optional progress reporting
    func deleteAllFolders(progressHandler: PurgeProgressHandler?) throws

    /// Deletes specified folders with optional progress reporting
    func deleteFolders(_ folders: [PurgeFolder], progressHandler: PurgeProgressHandler?) throws

    /// Opens a folder at the specified URL
    func openFolder(at url: URL) throws
}

/// Convenience extensions for PurgeService to support calls without progress handlers
public extension PurgeService {
    func deleteAllFolders() throws {
        try deleteAllFolders(progressHandler: nil)
    }

    func deleteFolders(_ folders: [PurgeFolder]) throws {
        try deleteFolders(folders, progressHandler: nil)
    }
}

/// Protocol for receiving progress updates during folder deletion operations
public protocol PurgeProgressHandler {
    /// Called after each folder is successfully deleted
    func didDeleteFolder(_ folder: PurgeFolder)
}
