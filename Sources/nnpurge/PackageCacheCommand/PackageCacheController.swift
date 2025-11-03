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
    private let progressHandler: any PackageCacheProgressHandler

    init(picker: any CommandLinePicker, service: any PackageCacheService, progressHandler: any PackageCacheProgressHandler) {
        self.picker = picker
        self.service = service
        self.progressHandler = progressHandler
    }
}


// MARK: - Open
extension PackageCacheController {
    func openPackageCacheFolder() throws {
        let path = "~/Library/Caches/org.swift.swiftpm/repositories"
        let expandedPath = NSString(string: path).expandingTildeInPath
        let url = URL(fileURLWithPath: expandedPath)

        try service.openFolder(at: url)
    }
}


// MARK: - Delete
extension PackageCacheController {
    func deletePackageCache(deleteAll: Bool) throws {
        let option = try selectOption(deleteAll: deleteAll)
        let allFolders = try service.loadFolders()

        switch option {
        case .deleteAll:
            try picker.requiredPermission(prompt: "Are you sure you want to delete all cached package repositories?")

            try service.deleteAllPackages(progressHandler: progressHandler)
        case .selectFolders:
            let foldersToDelete = picker.multiSelection("Select the package repositories to delete.", items: allFolders)

            try service.deleteFolders(foldersToDelete, progressHandler: progressHandler)
        }
    }
}


// MARK: - Private Methods
private extension PackageCacheController {
    func selectOption(deleteAll: Bool) throws -> DeleteOption {
        if deleteAll {
            return .deleteAll
        }

        return try picker.requiredSingleSelection("What would you like to do?", items: DeleteOption.allCases)
    }
}
