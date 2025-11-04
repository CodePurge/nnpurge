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
        let configuration = PurgeControllerConfiguration(
            deleteAllPrompt: "Are you sure you want to delete all cached package repositories?",
            selectionPrompt: "Select the package repositories to delete.",
            pathProvider: {
                let path = "~/Library/Caches/org.swift.swiftpm/repositories"
                return NSString(string: path).expandingTildeInPath
            }
        )

        self.controller = GenericPurgeController(
            picker: picker,
            service: service,
            progressHandler: progressHandler,
            configuration: configuration
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
