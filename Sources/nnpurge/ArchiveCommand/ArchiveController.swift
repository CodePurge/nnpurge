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
        print("should open archive folder") // TODO: -
    }
}


// MARK: - Delete
extension ArchiveController {
    func deleteArchives(deleteAll: Bool) throws {
        let archivesToDelete = try selectArchivesToDelete(deleteAll: deleteAll)
        
        try service.deleteArchives(archivesToDelete, progressHandler: progressHandler)
    }
}


// MARK: - Private Methods
private extension ArchiveController {
    func selectArchivesToDelete(deleteAll: Bool) throws -> [ArchiveFolder] {
        let allArchives = try service.loadArchives()
        let option = try selectOption(deleteAll: deleteAll)
        
        switch option {
        case .deleteAll:
            try picker.requiredPermission("Are you sure you want to delete all Xcode archives?")
            
            return allArchives
        case .selectFolders:
            return picker.multiSelection("Select the archives to delete.", items: allArchives)
        }
    }
    
    func selectOption(deleteAll: Bool) throws -> ArchiveOption {
        if deleteAll {
            return .deleteAll
        }

        return try picker.requiredSingleSelection("What would you like to do?", items: ArchiveOption.allCases)
    }
}


// MARK: - Dependencies
enum ArchiveOption: CaseIterable {
    case deleteAll, selectFolders
}


// MARK: - Extension Dependencies
extension ArchiveOption: DisplayablePickerItem {
    var displayName: String {
        switch self {
        case .deleteAll:
            return "Delete all archives"
        case .selectFolders:
            return "Select specific archives to delete"
        }
    }
}
