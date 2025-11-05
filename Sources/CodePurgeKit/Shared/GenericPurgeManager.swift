////
////  GenericPurgeManager.swift
////  CodePurgeKit
////
////  Created by Nikolai Nobadi on 11/3/25.
////
//
//import Foundation
//
//public struct GenericPurgeManager {
//    private let delegate: any PurgeDelegate
//    private let configuration: PurgeConfiguration
//    
//    init(configuration: PurgeConfiguration, delegate: any PurgeDelegate) {
//        self.delegate = delegate
//        self.configuration = configuration
//    }
//}
//
//
//// MARK: - PurgeService
//extension GenericPurgeManager: PurgeService {
//    public func loadFolders() throws -> [OldPurgeFolder] {
//        let path = configuration.expandPath
//            ? NSString(string: configuration.path).expandingTildeInPath
//            : configuration.path
//        return try delegate.loadFolders(path: path)
//    }
//
//    public func deleteAllFolders(progressHandler: PurgeProgressHandler?) throws {
//        let allFolders = try loadFolders()
//        
//        try deleteFolders(allFolders, progressHandler: progressHandler)
//    }
//
//    public func deleteFolders(_ folders: [OldPurgeFolder], progressHandler: PurgeProgressHandler?) throws {
//        let total = folders.count
//        
//        for (index, folder) in folders.enumerated() {
//            try delegate.deleteFolder(folder)
//            progressHandler?.updateProgress(current: index + 1, total: total, message: "Moving \(folder.name) to trash...")
//        }
//        
//        progressHandler?.complete(message: "✅ All items moved to trash.")
//    }
//
//    public func openFolder(at url: URL) throws {
//        try delegate.openFolder(at: url)
//    }
//}
//
//
//// MARK: - Dependencies
//protocol PurgeDelegate {
//    func deleteFolder(_ folder: OldPurgeFolder) throws
//    func loadFolders(path: String) throws -> [OldPurgeFolder]
//    func openFolder(at url: URL) throws
//}
//
//public struct PurgeConfiguration {
//    public let path: String
//    public let expandPath: Bool
//
//    public init(path: String, expandPath: Bool = true) {
//        self.path = path
//        self.expandPath = expandPath
//    }
//}
