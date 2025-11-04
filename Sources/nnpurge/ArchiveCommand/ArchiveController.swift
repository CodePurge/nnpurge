//
//  ArchiveController.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/4/25.
//

import Foundation
import SwiftPicker
import CodePurgeKit

struct ArchiveController {
    private let picker: any CommandLinePicker
    private let service: any ArchiveService
    private let progressHandler: any PurgeProgressHandler
    private let controller: GenericPurgeController

    init(picker: any CommandLinePicker, service: any ArchiveService, progressHandler: any PurgeProgressHandler) {
        self.picker = picker
        self.service = service
        self.progressHandler = progressHandler
        self.controller = .init(
            picker: picker,
            service: service,
            progressHandler: progressHandler,
            configuration: .archiveConfiguration
        )
    }
}


// MARK: - Open
extension ArchiveController {
    func openArchiveFolder() throws {
        try controller.openFolder()
    }
}


// MARK: - Delete
extension ArchiveController {
    func deleteArchives(deleteAll: Bool) throws {
        try controller.deleteFolders(deleteAll: deleteAll)
    }
}


// MARK: - Configuration
private extension PurgeControllerConfiguration {
    static var archiveConfiguration: PurgeControllerConfiguration {
        let path = NSString(string: "~/Library/Developer/Xcode/Archives").expandingTildeInPath

        return .init(
            deleteAllPrompt: "Are you sure you want to delete all Xcode archives?",
            selectionPrompt: "Select the archives to delete.",
            path: path,
            availableOptions: [
                .init(.deleteAll, displayName: "Delete all archives"),
                .init(.deleteStale, displayName: "Delete stale archives (90+ days old)"),
                .init(.selectFolders, displayName: "Select specific archives to delete")
            ],
            staleDaysThreshold: 90
        )
    }
}
