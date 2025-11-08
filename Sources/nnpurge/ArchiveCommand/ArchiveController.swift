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
    private let xcodeHandler: XcodeRunningHandler

    init(picker: any CommandLinePicker, service: any ArchiveService, progressHandler: any PurgeProgressHandler) {
        self.picker = picker
        self.service = service
        self.progressHandler = progressHandler
        self.xcodeHandler = .init(picker: picker, progressHandler: progressHandler)
    }
}


// MARK: - Open
extension ArchiveController {
    func openArchiveFolder() throws {
        print("should open archive folder") // TODO: -
    }
}


// MARK: - Delete
extension ArchiveController {
    func deleteArchives() throws {
        let archivesToDelete = try selectArchivesToDelete()

        do {
            // TODO: - Progress handler removed for now as it's not needed
            try service.deleteArchives(archivesToDelete, force: false, progressHandler: nil)
        } catch ArchiveError.xcodeIsRunning {
            try handleXcodeRunning(archivesToDelete: archivesToDelete)
        }
    }
}


// MARK: - Private Methods
private extension ArchiveController {
    func selectArchivesToDelete() throws -> [ArchiveFolder] {
        let allArchives = try service.loadArchives()
        let option = try picker.requiredSingleSelection("What would you like to do?", items: ArchiveOption.allCases)

        switch option {
        case .deleteStale:
            let staleArchives = filterStaleArchives(allArchives, daysOld: 30)

            guard !staleArchives.isEmpty else {
                print("No stale archives found (30+ days old).")
                return []
            }

            try picker.requiredPermission("Found \(staleArchives.count) stale archive(s). Delete them?")

            return staleArchives
        case .selectFolders:
            return picker.multiSelection("Select the archives to delete.", items: allArchives)
        }
    }

    func filterStaleArchives(_ archives: [ArchiveFolder], daysOld: Int) -> [ArchiveFolder] {
        let calendar = Calendar.current
        let now = Date()
        let daysAgo = calendar.date(byAdding: .day, value: -daysOld, to: now) ?? now

        return archives.filter { archive in
            let dateToCheck = archive.modificationDate ?? archive.creationDate

            guard let date = dateToCheck else {
                return false
            }

            return date < daysAgo
        }
    }

    func handleXcodeRunning(archivesToDelete: [ArchiveFolder]) throws {
        try xcodeHandler.handle(
            itemsToDelete: archivesToDelete,
            deleteOperation: service.deleteArchives,
            xcodeFailedToCloseError: ArchiveError.xcodeFailedToClose
        )
    }
}


// MARK: - Dependencies
enum ArchiveOption: CaseIterable {
    case deleteStale, selectFolders
}


// MARK: - Extension Dependencies
extension ArchiveOption: DisplayablePickerItem {
    var displayName: String {
        switch self {
        case .deleteStale:
            return "Delete stale archives (30+ days old)"
        case .selectFolders:
            return "Select specific archives to delete"
        }
    }
}
