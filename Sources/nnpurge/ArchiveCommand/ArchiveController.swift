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

    init(picker: any CommandLinePicker, service: any ArchiveService, progressHandler: any PurgeProgressHandler) {
        self.picker = picker
        self.service = service
        self.progressHandler = progressHandler
    }
}


// MARK: - Open
extension ArchiveController {
    func openArchiveFolder() throws {
//        try controller.openFolder()
    }
}


// MARK: - Delete
extension ArchiveController {
    func deleteArchives(deleteAll: Bool) throws {
        let option = try selectOption(deleteAll: deleteAll)
        let allArchives = try service.loadArchives()
        
        switch option {
        case .deleteAll:
            try picker.requiredPermission("") // TODO: -
        case .deleteStale:
            break
        case .selectFolders:
            let archivesToDelete = picker.multiSelection("", items: allArchives)
            
            print("delete \(archivesToDelete.count) archives")
        }
    }
}


// MARK: - Private Methods
private extension ArchiveController {
    func selectOption(deleteAll: Bool) throws -> DeleteOption {
        if deleteAll {
            return .deleteAll
        }

        let selectedDisplayable = try picker.requiredSingleSelection("What would you like to do?", items: makeOptions())

        return selectedDisplayable.option
    }
    
    func makeOptions() -> [DisplayableDeleteOption] {
        return [
            .init(.deleteAll, displayName: "Delete all archives"),
            .init(.deleteStale, displayName: "Delete stale archives (90+ days old)"),
            .init(.selectFolders, displayName: "Select specific archives to delete")
        ]
    }
}

extension ArchiveFolder: DisplayablePickerItem {
    public var displayName: String {
        return name // TODO: -
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
