//
//  DerivedDataController.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 10/26/25.
//

import SwiftPicker
import CodePurgeKit

struct DerivedDataController {
    private let picker: CommandLinePicker
    private let service: DerivedDataService

    init(picker: CommandLinePicker, service: DerivedDataService) {
        self.picker = picker
        self.service = service
    }
}


// MARK: - Actions
extension DerivedDataController {
    func deleteDerivedData(deleteAll: Bool) throws {
        let option = try selectOption(deleteAll: deleteAll)
        let allFolders = try service.loadFolders()

        switch option {
        case .deleteAll:
            try picker.requiredPermission(prompt: "Are you sure you want to delete all derived data?")

            try service.deleteAllDerivedData()
        case .selectFolders:
            let foldersToDelete = picker.multiSelection("Select the folders to delete.", items: allFolders)

            try service.deleteFolders(foldersToDelete)
        }
    }
}


// MARK: - Private Methods
private extension DerivedDataController {
    func selectOption(deleteAll: Bool) throws -> DeleteOption {
        if deleteAll {
            return .deleteAll
        }
        
        return try picker.requiredSingleSelection("What would you like to do?", items: DeleteOption.allCases)
    }
}
