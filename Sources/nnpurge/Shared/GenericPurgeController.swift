//
//  GenericPurgeController.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Foundation
import SwiftPicker
import CodePurgeKit

/// Configuration for purge controller prompts
struct PurgeControllerConfiguration {
    let deleteAllPrompt: String
    let selectionPrompt: String
    let pathProvider: () -> String

    init(deleteAllPrompt: String, selectionPrompt: String, pathProvider: @escaping () -> String) {
        self.deleteAllPrompt = deleteAllPrompt
        self.selectionPrompt = selectionPrompt
        self.pathProvider = pathProvider
    }
}

/// Generic controller for purge operations
struct GenericPurgeController {
    private let picker: any CommandLinePicker
    private let service: any PurgeService
    private let progressHandler: any PurgeProgressHandler
    private let configuration: PurgeControllerConfiguration

    init(picker: any CommandLinePicker, service: any PurgeService, progressHandler: any PurgeProgressHandler, configuration: PurgeControllerConfiguration) {
        self.picker = picker
        self.service = service
        self.progressHandler = progressHandler
        self.configuration = configuration
    }
}


// MARK: - Open
extension GenericPurgeController {
    func openFolder() throws {
        let path = configuration.pathProvider()
        let url = URL(fileURLWithPath: path)

        try service.openFolder(at: url)
    }
}


// MARK: - Delete
extension GenericPurgeController {
    func deleteFolders(deleteAll: Bool) throws {
        let option = try selectOption(deleteAll: deleteAll)
        let allFolders = try service.loadFolders()

        switch option {
        case .deleteAll:
            try picker.requiredPermission(prompt: configuration.deleteAllPrompt)

            try service.deleteAllFolders(progressHandler: progressHandler)
        case .selectFolders:
            let foldersToDelete = picker.multiSelection(configuration.selectionPrompt, items: allFolders)

            try service.deleteFolders(foldersToDelete, progressHandler: progressHandler)
        }
    }
}


// MARK: - Private Methods
private extension GenericPurgeController {
    func selectOption(deleteAll: Bool) throws -> DeleteOption {
        if deleteAll {
            return .deleteAll
        }

        return try picker.requiredSingleSelection("What would you like to do?", items: DeleteOption.allCases)
    }
}
