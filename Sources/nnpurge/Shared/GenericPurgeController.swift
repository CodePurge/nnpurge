//
//  GenericPurgeController.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Foundation
import SwiftPicker
import CodePurgeKit

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
        let url = URL(fileURLWithPath: configuration.path)

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
        case .deleteStale:
            let staleFolders = PurgeFolder.filterStale(allFolders, olderThanDays: configuration.staleDaysThreshold)
            try picker.requiredPermission(prompt: configuration.deleteStalePrompt)

            try service.deleteFolders(staleFolders, progressHandler: progressHandler)
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

        let selectedDisplayable = try picker.requiredSingleSelection("What would you like to do?", items: configuration.availableOptions)

        return selectedDisplayable.option
    }
}


// MARK: - Dependencies
struct PurgeControllerConfiguration {
    let path: String
    let deleteAllPrompt: String
    let deleteStalePrompt: String
    let selectionPrompt: String
    let availableOptions: [DisplayableDeleteOption]
    let staleDaysThreshold: Int

    init(deleteAllPrompt: String, selectionPrompt: String, path: String, deleteStalePrompt: String = "", availableOptions: [DisplayableDeleteOption], staleDaysThreshold: Int = 30) {
        self.path = path
        self.deleteAllPrompt = deleteAllPrompt
        self.deleteStalePrompt = deleteStalePrompt
        self.selectionPrompt = selectionPrompt
        self.availableOptions = availableOptions
        self.staleDaysThreshold = staleDaysThreshold
    }
}
