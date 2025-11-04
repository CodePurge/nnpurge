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
    private let store: any DerivedDataStore
    private let controller: GenericPurgeController

    init(store: any DerivedDataStore, picker: any CommandLinePicker, service: any DerivedDataService, progressHandler: any DerivedDataProgressHandler) {
        self.store = store

        self.controller = .init(
            picker: picker,
            service: service,
            progressHandler: progressHandler,
            configuration: .derivedDataConfiguration(store: store)
        )
    }
}


// MARK: - Open
extension DerivedDataController {
    func openDerivedDataFolder() throws {
        try controller.openFolder()
    }
}


// MARK: - Delete
extension DerivedDataController {
    func deleteDerivedData(deleteAll: Bool) throws {
        try controller.deleteFolders(deleteAll: deleteAll)
    }
}


// MARK: - Path
extension DerivedDataController {
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


// MARK: - Configuration
private extension PurgeControllerConfiguration {
    static func derivedDataConfiguration(store: any DerivedDataStore) -> PurgeControllerConfiguration {
        return .init(
            deleteAllPrompt: "Are you sure you want to delete all derived data?",
            selectionPrompt: "Select the folders to delete.",
            path: store.loadDerivedDataPath(),
            availableOptions: [
                .init(.deleteAll, displayName: "Delete all derived data folders"),
                .init(.selectFolders, displayName: "Select specific folders to delete")
            ]
        )
    }
}

private extension String {
    static var derivedDataPathKey: String {
        return "derivedDataPathKey"
    }
}
