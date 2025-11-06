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
    private let xcodeChecker: any XcodeStatusChecker
    private let xcodeTerminator: any XcodeTerminator
    private let deletionHelper: PurgableItemDeletionHelper

    init(config: ArchiveConfig, loader: any PurgeFolderLoader, delegate: any ArchiveDelegate, xcodeChecker: any XcodeStatusChecker, xcodeTerminator: any XcodeTerminator) {
        self.config = config
        self.loader = loader
        self.delegate = delegate
        self.xcodeChecker = xcodeChecker
        self.xcodeTerminator = xcodeTerminator
        self.deletionHelper = PurgableItemDeletionHelper(deleter: delegate, xcodeChecker: xcodeChecker)
    }
}


// MARK: - Init
public extension ArchiveManager {
    init() {
        self.init(config: .defaultConfig, loader: DefaultPurgeFolderLoader(), delegate: DefaultArchiveDelegate(), xcodeChecker: DefaultXcodeStatusChecker(), xcodeTerminator: DefaultXcodeTerminator())
    }
}


// MARK: - Actions
extension ArchiveManager: ArchiveService {
    public func loadArchives() throws -> [ArchiveFolder] {
        return try loader.loadPurgeFolders(at: config.path).compactMap({ makeArchive(folder: $0) })
    }

    public func deleteArchives(_ archives: [ArchiveFolder], force: Bool, progressHandler: (any PurgeProgressHandler)?) throws {
        try deletionHelper.deleteItems(
            archives,
            force: force,
            progressHandler: progressHandler,
            completionMessage: "✅ Archives moved to trash.",
            xcodeRunningError: ArchiveError.xcodeIsRunning
        )
    }

    public func closeXcodeAndVerify(timeout: TimeInterval = 10.0) throws {
        guard xcodeTerminator.terminateXcode() else {
            throw ArchiveError.xcodeFailedToClose
        }

        let pollInterval = 0.5
        var elapsed = 0.0

        while xcodeChecker.isXcodeRunning() && elapsed < timeout {
            Thread.sleep(forTimeInterval: pollInterval)
            elapsed += pollInterval
        }

        if xcodeChecker.isXcodeRunning() {
            throw ArchiveError.xcodeFailedToClose
        }
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
protocol ArchiveDelegate: PurgableItemDeleter {
    func deleteArchive(_ archive: ArchiveFolder) throws
    func parseFolderPList(_ folder: any PurgeFolder) -> [String: Any]?
}

public enum ArchiveError: Error, Equatable {
    case xcodeIsRunning
    case xcodeFailedToClose
}
