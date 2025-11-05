//
//  ArchiveManager.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 11/4/25.
//

import Foundation

public struct ArchiveManager {
    private let path: String
    private let loader: any PurgeFolderLoader
    private let delegate: any ArchiveDelegate
    
    init(loader: any PurgeFolderLoader, delegate: any ArchiveDelegate) {
        self.loader = loader
        self.delegate = delegate
        self.path = NSString(string: "~/Library/Developer/Xcode/Archives").expandingTildeInPath
    }
}


// MARK: - Init
public extension ArchiveManager {
    init() {
        self.init(loader: DefaultPurgeFolderLoader(), delegate: DefaultArchiveDelegate())
    }
}


// MARK: - Actions
extension ArchiveManager: ArchiveService {
    public func loadArchives() throws -> [ArchiveFolder] {
        let purgeFolders = try loader.loadPurgeFolders(at: path)
        
        return makeArchives(from: purgeFolders)
    }
    
    public func deleteArchives(_ archives: [ArchiveFolder], progressHandler: (any PurgeProgressHandler)?) throws {
        let total = archives.count
        
        for (index, folder) in archives.enumerated() {
            try delegate.deleteArchive(folder)
            progressHandler?.updateProgress(current: index + 1, total: total, message: "Moving \(folder.name) to trash...")
        }
        
        progressHandler?.complete(message: "✅ Archives moved to trash.")
    }
}


// MARK: - Private Methods
private extension ArchiveManager {
    func makeArchives(from folders: [any PurgeFolder]) -> [ArchiveFolder] {
        return [] // TODO: -
    }
}


// MARK: - Dependencies
protocol ArchiveDelegate {
    func deleteArchive(_ archive: ArchiveFolder) throws
}
