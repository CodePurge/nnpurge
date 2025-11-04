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
    private let controller: GenericPurgeController

    init(picker: any CommandLinePicker, service: any PackageCacheService, progressHandler: any PackageCacheProgressHandler) {
        self.controller = .init(
            picker: picker,
            service: service,
            progressHandler: progressHandler,
            configuration: .packageCacheConfiguration
        )
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


// MARK: - Configuration
private extension PurgeControllerConfiguration {
    static var packageCacheConfiguration: PurgeControllerConfiguration {
        let path = NSString(string: "~/Library/Caches/org.swift.swiftpm/repositories").expandingTildeInPath

        return .init(
            deleteAllPrompt: "Are you sure you want to delete all cached package repositories?",
            selectionPrompt: "Select the package repositories to delete.",
            path: path,
            deleteStalePrompt: "Are you sure you want to delete stale packages (not modified in 30+ days)?",
            availableOptions: [
                .init(.deleteAll, displayName: "Delete all package repositories"),
                .init(.deleteStale, displayName: "Delete stale packages (30+ days old)"),
                .init(.selectFolders, displayName: "Select specific packages to delete")
            ],
            staleDaysThreshold: 30
        )
    }
}
