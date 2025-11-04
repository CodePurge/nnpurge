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
    
    init(loader: any PurgeFolderLoader) {
        self.loader = loader
        self.path = NSString(string: "~/Library/Developer/Xcode/Archives").expandingTildeInPath
    }
}


// MARK: - Init
public extension ArchiveManager {
    init() {
        self.init(loader: DefaultPurgeFolderLoader())
    }
}


// MARK: - Actions
extension ArchiveManager: ArchiveService {
    public func loadArchives() throws -> [ArchiveFolder] {
        let purgeFolders = try loader.loadPurgeFolders(at: path)
        
        return makeArchives(from: purgeFolders)
    }
    
    public func deleteArchives(_ archives: [ArchiveFolder], progressHandler: (any PurgeProgressHandler)?) throws {
        // TODO: -
    }
    
    public func deleteAllArchives(progressHandler: PurgeProgressHandler?) throws {
//        try manager.deleteAllFolders(progressHandler: progressHandler)
    }
}


// MARK: - Private Methods
private extension ArchiveManager {
    func makeArchives(from folders: [any PurgeFolder]) -> [ArchiveFolder] {
        return [] // TODO: -
    }
}

protocol PurgeFolderLoader {
    func loadPurgeFolders(at path: String) throws -> [any PurgeFolder]
}

struct DefaultPurgeFolderLoader: PurgeFolderLoader {
    func loadPurgeFolders(at path: String) throws -> [any PurgeFolder] {
        return try Folder(path: path).subfolders.map({ PurgeFolderContainer(folder: $0) })
    }
}

import Files

struct PurgeFolderContainer {
    private let folder: Folder
    
    init(folder: Folder) {
        self.folder = folder
    }
}

extension PurgeFolderContainer: PurgeFolder {
    var url: URL {
        return folder.url
    }
    
    var name: String {
        return folder.name
    }
    
    var path: String {
        return folder.path
    }
    
    var creationDate: Date? {
        return folder.creationDate
    }
    
    var modificationDate: Date? {
        return folder.modificationDate
    }
    
    var subfolders: [PurgeFolderContainer] {
        return folder.subfolders.map({ .init(folder: $0) })
    }
    
    func getSize() -> Int64 {
        return 0 // TODO: - 
    }
}
