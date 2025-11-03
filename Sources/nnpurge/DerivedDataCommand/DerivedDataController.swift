//
//  DerivedDataController.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 10/26/25.
//

import Foundation
import SwiftPicker
import CodePurgeKit

struct DerivedDataController {
    private let store: DerivedDataStore
    private let picker: CommandLinePicker
    private let service: any DerivedDataService

    init(store: DerivedDataStore, picker: CommandLinePicker, service: any DerivedDataService) {
        self.store = store
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

    func managePath(set newPath: String?, reset: Bool) -> String {
        if reset {
            store.set(nil, forKey: .derivedDataPathKey)
            return "Derived data path reset to default: ~/Library/Developer/Xcode/DerivedData"
        }

        if let newPath {
            let expandedPath = NSString(string: newPath).expandingTildeInPath
            store.set(expandedPath, forKey: .derivedDataPathKey)
            return "Derived data path set to: \(expandedPath)"
        }

        let currentPath = store.loadDerivedDataPath()
        let isDefault = store.string(forKey: .derivedDataPathKey) == nil
        var message = "Current derived data path: \(currentPath)"
        if isDefault {
            message += "\n(using default)"
        }
        return message
    }

    func openDerivedDataFolder() throws {
        let path = store.loadDerivedDataPath()
        let url = URL(fileURLWithPath: path)

        try service.openFolder(at: url)
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


// MARK: - Dependencies
protocol DerivedDataStore {
    func string(forKey defaultName: String) -> String?
    func set(_ value: Any?, forKey defaultName: String)
}


// MARK: - Extension Dependencies
extension DerivedDataStore {
    func loadDerivedDataPath() -> String {
        let path = string(forKey: .derivedDataPathKey) ?? "~/Library/Developer/Xcode/DerivedData"

        return NSString(string: path).expandingTildeInPath
    }
}

private extension String {
    static var derivedDataPathKey: String {
        return "derivedDataPathKey"
    }
}
