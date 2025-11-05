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


// MARK: - Extension Dependencies
private extension ArchiveFolder {
    init(folder: any PurgeFolder) {
        self.init(
            url: folder.url,
            name: folder.name,
            path: folder.path,
            creationDate: folder.creationDate,
            modificationDate: folder.modificationDate,
            imageData: nil,
            uploadStatus: nil,
            versionNumber: nil
        )
    }
}

private extension PurgeFolder {
    func parseInfoPlist() -> [String: Any]? {
        guard let path = getFilePath(named: "Info.plist"),
              let data = FileManager.default.contents(atPath: path)
        else {
            print("Failed to read data from plist path")
            return nil
        }
        
        do {
            let plistData = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            guard let dictionary = plistData as? [String: Any] else {
                print("Failed to cast plist data to [String: Any]")
                return nil
            }
            return dictionary
        } catch {
            print("Error parsing plist: \(error)")
            return nil
        }
    }
}
