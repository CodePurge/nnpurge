//
//  PackageCacheController.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Foundation
import SwiftPicker
import CodePurgeKit

struct PackageCacheController {
    private let picker: any CommandLinePicker
    private let service: any PackageCacheService
    private let progressHandler: any PurgeProgressHandler
    private let controller: GenericPurgeController

    init(picker: any CommandLinePicker, service: any PackageCacheService, progressHandler: any PurgeProgressHandler) {
        fatalError() // TODO: - 
//        self.picker = picker
//        self.service = service
//        self.progressHandler = progressHandler
//        self.controller = .init(
//            picker: picker,
//            service: service,
//            progressHandler: progressHandler,
//            configuration: .packageCacheConfiguration
//        )
    }
}


// MARK: - Open
extension PackageCacheController {
    func openPackageCacheFolder() throws {
        try controller.openFolder()
    }
}


// MARK: - Delete
extension PackageCacheController {
    func deletePackageCache(deleteAll: Bool) throws {
        try controller.deleteFolders(deleteAll: deleteAll)
    }
}


// MARK: - Clean Project Dependencies
extension PackageCacheController {
    func cleanProjectDependencies(projectPath: String?) throws {
        // TODO: - 
//        let dependencies = try service.findDependencies(in: projectPath)
//        let allFolders = try service.loadFolders()
//        let matchedFolders = OldPurgeFolder.filterByDependencies(allFolders, identities: dependencies.packageIdentities)
//
//        guard !matchedFolders.isEmpty else {
//            print("No cached packages found for project dependencies.")
//            return
//        }
//
//        print("\nFound \(matchedFolders.count) cached \(matchedFolders.count == 1 ? "package" : "packages") matching project dependencies:")
//        for folder in matchedFolders {
//            print("  - \(folder.name)")
//        }
//
//        let prompt = "\nDelete these \(matchedFolders.count) cached \(matchedFolders.count == 1 ? "package" : "packages")?"
//        try picker.requiredPermission(prompt: prompt)
//
//        try service.deleteFolders(matchedFolders, progressHandler: progressHandler)
    }
}


// MARK: - Configuration
private extension PurgeControllerConfiguration {
    static var packageCacheConfiguration: PurgeControllerConfiguration {
        let path = NSString(string: "~/Library/Caches/org.swift.swiftpm/repositories").expandingTildeInPath

        return .init(
            deleteAllPrompt: "Are you sure you want to delete all cached package repositories?",
            selectionPrompt: "Select the package repositories to delete.",
            path: path,
            availableOptions: [
                .init(.deleteAll, displayName: "Delete all package repositories"),
                .init(.deleteStale, displayName: "Delete stale packages (30+ days old)"),
                .init(.selectFolders, displayName: "Select specific packages to delete")
            ],
            staleDaysThreshold: 30
        )
    }
}
