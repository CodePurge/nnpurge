//
//  PackageCacheController.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Foundation
import CodePurgeKit

struct PackageCacheController {
    private let staleDaysThreshold: Int
    private let picker: any PurgePicker
    private let service: any PackageCacheService
    private let progressHandler: any PurgeProgressHandler
    private let xcodeHandler: XcodeRunningHandler

    init(staleDaysThreshold: Int = 30, picker: any PurgePicker, service: any PackageCacheService, progressHandler: any PurgeProgressHandler) {
        self.picker = picker
        self.service = service
        self.progressHandler = progressHandler
        self.staleDaysThreshold = staleDaysThreshold
        self.xcodeHandler = .init(picker: picker, progressHandler: progressHandler)
    }
}


// MARK: - Open
extension PackageCacheController {
    func openPackageCacheFolder() throws {
        print("should open Package Cache Repositories folder") // TODO: -
    }
}


// MARK: - Delete
extension PackageCacheController {
    func deletePackageCache(deleteAll: Bool) throws {
        let foldersToDelete = try selectFoldersToDelete(deleteAll: deleteAll)

        do {
            // TODO: - Progress handler removed for now as it's not needed
            try service.deleteFolders(foldersToDelete, force: false, progressHandler: nil)
        } catch PackageCacheError.xcodeIsRunning {
            try handleXcodeRunning(foldersToDelete: foldersToDelete)
        }
    }
}


// MARK: - Clean Project Dependencies
extension PackageCacheController {
    func cleanProjectDependencies(projectPath: String?) throws {
        let allFolders = try service.loadFolders()
        let dependencies = try service.findDependencies(in: projectPath)
        let matchedFolders = PackageCacheFolder.filterByDependencies(allFolders, identities: dependencies.packageIdentities)

        guard !matchedFolders.isEmpty else {
            print("No cached packages found for project dependencies.")
            return
        }

        print("\nFound \(matchedFolders.count) cached \(matchedFolders.count == 1 ? "package" : "packages") matching project dependencies:")
        for folder in matchedFolders {
            print("  - \(folder.name)")
        }

        try picker.requiredPermission("\nDelete these \(matchedFolders.count) cached \(matchedFolders.count == 1 ? "package" : "packages")?")

        do {
            try service.deleteFolders(matchedFolders, force: false, progressHandler: progressHandler)
        } catch PackageCacheError.xcodeIsRunning {
            try handleXcodeRunning(foldersToDelete: matchedFolders)
        }
    }
}


// MARK: - Private Methods
private extension PackageCacheController {
    func selectFoldersToDelete(deleteAll: Bool) throws -> [PackageCacheFolder] {
        let allFolders = try service.loadFolders()
        let option = try selectOption(deleteAll: deleteAll)
        
        switch option {
        case .deleteAll:
            try picker.requiredPermission("Are you sure you want to delete all package repositories?")

            return allFolders
        case .deleteStale:
            let staleFolders = PackageCacheFolder.filterStale(allFolders, olderThanDays: staleDaysThreshold)
            let count = staleFolders.count
            try picker.requiredPermission(
                "Are you sure you want to delete \(count) stale \(count == 1 ? "package" : "packages") (not modified in \(staleDaysThreshold)+ days)?"
            )

            return staleFolders
        case .selectFolders:
            return picker.multiSelection("Select the folders to delete.", items: allFolders)
        }
    }
    
    func selectOption(deleteAll: Bool) throws -> PackageCacheDeleteOption {
        if deleteAll {
            return .deleteAll
        }

        return try picker.requiredSingleSelection("What would you like to do?", items: PackageCacheDeleteOption.allCases)
    }

    func handleXcodeRunning(foldersToDelete: [PackageCacheFolder]) throws {
        try xcodeHandler.handle(
            itemsToDelete: foldersToDelete,
            deleteOperation: service.deleteFolders,
            xcodeFailedToCloseError: PackageCacheError.xcodeFailedToClose
        )
    }
}


// MARK: - Extension Dependencies
extension PackageCacheFolder {
    static func filterByDependencies(_ folders: [PackageCacheFolder], identities: [String]) -> [PackageCacheFolder] {
        let lowercaseIdentities = Set(identities.map { $0.lowercased() })

        return folders.filter { folder in
            guard let packageName = folder.packageName else {
                return false
            }
            
            return lowercaseIdentities.contains(packageName.lowercased())
        }
    }
    
    private var packageName: String? {
        guard let lastDashIndex = name.lastIndex(of: "-") else {
            return nil
        }
        
        return String(name[..<lastDashIndex])
    }
    
    static func filterStale(_ folders: [PackageCacheFolder], olderThanDays days: Int) -> [PackageCacheFolder] {
        let calendar = Calendar.current
        let threshold = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()

        return folders.filter { folder in
            if folder.modificationDate == nil && folder.creationDate == nil {
                return true
            } else if let modificationDate = folder.modificationDate {
                return modificationDate < threshold
            } else if folder.modificationDate == nil, let creationDate = folder.creationDate {
                return creationDate < threshold
            }

            return false
        }
    }
}
