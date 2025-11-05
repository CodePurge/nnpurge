//
//  ArchiveManager.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 11/4/25.
//

import Foundation

public struct ArchiveManager {
    private let config: ArchiveConfig
    private let loader: any PurgeFolderLoader
    private let delegate: any ArchiveDelegate
    
    init(config: ArchiveConfig, loader: any PurgeFolderLoader, delegate: any ArchiveDelegate) {
        self.config = config
        self.loader = loader
        self.delegate = delegate
    }
}


// MARK: - Init
public extension ArchiveManager {
    init() {
        self.init(config: .defaultConfig, loader: DefaultPurgeFolderLoader(), delegate: DefaultArchiveDelegate())
    }
}


// MARK: - Actions
extension ArchiveManager: ArchiveService {
    public func loadArchives() throws -> [ArchiveFolder] {
        return try loader.loadPurgeFolders(at: config.path).compactMap({ makeArchive(folder: $0) })
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
    func makeArchive(folder: any PurgeFolder) -> ArchiveFolder? {
        guard let plist = delegate.parseFolderPList(folder) else {
            return nil
        }
        
        let name: String = plist["Name"] as? String ?? ""
        let size: Int64? = config.calculateSize ? folder.getSize() : nil
        let imageData: Data? = config.includeImageData ? folder.getImageData() : nil
        let creationDate = plist["CreationDate"] as? Date
        let appProperties = plist["ApplicationProperties"] as? [String: Any]
        let version = appProperties?["CFBundleShortVersionString"] as? String ?? ""
        let distributions = plist["Distributions"] as? [[String: Any]]
        let shortTitle = distributions?
            .compactMap { $0["uploadEvent"] as? [String: Any] }
            .compactMap { $0["shortTitle"] as? String }
            .first
        
        return .init(
            url: folder.url,
            name: name,
            path: folder.path,
            creationDate: creationDate,
            modificationDate: folder.modificationDate,
            size: size,
            imageData: imageData,
            uploadStatus: shortTitle,
            versionNumber: version
        )
    }
}


// MARK: - Dependencies
protocol ArchiveDelegate {
    func deleteArchive(_ archive: ArchiveFolder) throws
    func parseFolderPList(_ folder: any PurgeFolder) -> [String: Any]?
}
