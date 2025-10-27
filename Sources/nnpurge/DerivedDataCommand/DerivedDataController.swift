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
    private let manager: DerivedDataManager
    
    init(picker: CommandLinePicker, manager: DerivedDataManager) {
        self.picker = picker
        self.manager = manager
    }
}


// MARK: - Actions
extension DerivedDataController {
    func deleteDerivedData(deleteAll: Bool) throws {
        let allFolders = manager.loadFolders()
        let foldersToDelete: [PurgeFolder]

        if deleteAll {
            try picker.requiredPermission(prompt: "Are you sure you want to delete all derived data?")
            foldersToDelete = allFolders
        } else {
            let option = try picker.requiredSingleSelection("What would you like to do?", items: DeleteOption.allCases)

            switch option {
            case .deleteAll:
                try picker.requiredPermission(prompt: "Are you sure you want to delete all derived data?")
                foldersToDelete = allFolders
            case .selectFolders:
                foldersToDelete = picker.multiSelection("Select the folders to delete.", items: allFolders)
            }
        }

        try manager.deleteFolders(foldersToDelete)
    }
}

