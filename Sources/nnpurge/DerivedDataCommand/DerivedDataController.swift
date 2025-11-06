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
    private let picker: any CommandLinePicker
    private let service: any DerivedDataService
    private let progressHandler: any PurgeProgressHandler

    init(store: any DerivedDataStore, picker: any CommandLinePicker, service: any DerivedDataService, progressHandler: any PurgeProgressHandler) {
        self.store = store
        self.picker = picker
        self.service = service
        self.progressHandler = progressHandler
    }
}


// MARK: - Open
extension DerivedDataController {
    func openDerivedDataFolder() throws {
        print("should open DerivedData folder") // TODO: -
    }
}


// MARK: - Delete
extension DerivedDataController {
    func deleteDerivedData(deleteAll: Bool) throws {
        let foldersToDelete = try selectFoldersToDelete(deleteAll: deleteAll)

        do {
            try service.deleteFolders(foldersToDelete, force: false, progressHandler: progressHandler)
        } catch DerivedDataError.xcodeIsRunning {
            try handleXcodeRunning(foldersToDelete: foldersToDelete)
        }
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


// MARK: - Private Methods
private extension DerivedDataController {
    func selectFoldersToDelete(deleteAll: Bool) throws -> [DerivedDataFolder] {
        let allFolders = try service.loadFolders()
        let option = try selectOption(deleteAll: deleteAll)

        switch option {
        case .deleteAll:
            try picker.requiredPermission("Are you sure you want to delete all derived data?")

            return allFolders
        case .selectFolders:
            return picker.multiSelection("Select the folders to delete.", items: allFolders)
        }
    }

    func selectOption(deleteAll: Bool) throws -> DerivedDataDeleteOption {
        if deleteAll {
            return .deleteAll
        }

        return try picker.requiredSingleSelection("What would you like to do?", items: DerivedDataDeleteOption.allCases)
    }

    func handleXcodeRunning(foldersToDelete: [DerivedDataFolder]) throws {
        let option = try picker.requiredSingleSelection("Xcode is currently running. What would you like to do?", items: XcodeRunningOption.allCases)

        switch option {
        case .proceedAnyway:
            try service.deleteFolders(foldersToDelete, force: true, progressHandler: progressHandler)
        case .closeXcodeAndProceed:
            do {
                try service.closeXcodeAndVerify(timeout: 10.0)
                try service.deleteFolders(foldersToDelete, force: false, progressHandler: progressHandler)
            } catch DerivedDataError.xcodeFailedToClose {
                print("❌ Failed to close Xcode. Please close Xcode manually and try again.")
                throw DerivedDataError.xcodeFailedToClose
            }
        case .cancel:
            print("Operation cancelled.")
        }
    }
}


// MARK: - Dependencies
protocol DerivedDataStore {
    func string(forKey defaultName: String) -> String?
    func set(_ value: Any?, forKey defaultName: String)
}

enum DerivedDataDeleteOption: CaseIterable {
    case deleteAll, selectFolders
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

extension DerivedDataFolder: DisplayablePickerItem {
    public var displayName: String {
        return name
    }
}

extension DerivedDataDeleteOption: DisplayablePickerItem {
    var displayName: String {
        switch self {
        case .deleteAll:
            return "Delete all derived data folders"
        case .selectFolders:
            return "Select specific folders to delete"
        }
    }
}
