//
//  DerivedDataControllerTests.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 10/26/25.
//

import Testing
import Foundation
import SwiftPicker
import CodePurgeKit
import CodePurgeTesting
import SwiftPickerTesting
@testable import nnpurge

struct DerivedDataControllerTests {
    @Test("Starting values empty")
    func emptyStartingValues() {
        let (_, service, _) = makeSUT()

        #expect(!service.didDeleteAllDerivedData)
        #expect(service.deletedFolders.isEmpty)
    }
}


// MARK: - Delete All Flag Tests
extension DerivedDataControllerTests {
    @Test("Deletes all derived data when flag true and permission granted")
    func deletesAllDerivedDataWhenFlagTrueAndPermissionGranted() throws {
        let (sut, service, _) = makeSUT(
            permissionResult: .init(type: .ordered([true]))
        )

        try sut.deleteDerivedData(deleteAll: true)

        #expect(service.didDeleteAllDerivedData)
    }

    @Test("Throws error when delete all flag true but permission denied")
    func throwsErrorWhenDeleteAllFlagTrueButPermissionDenied() throws {
        let (sut, _, _) = makeSUT(
            permissionResult: .init(type: .ordered([false]))
        )

        #expect(throws: SwiftPickerError.selectionCancelled) {
            try sut.deleteDerivedData(deleteAll: true)
        }
    }

    @Test("Requests permission with correct prompt when deleting all")
    func requestsPermissionWithCorrectPromptWhenDeletingAll() throws {
        let expectedPrompt = "Are you sure you want to delete all derived data?"
        let (sut, _, _) = makeSUT(
            permissionResult: .init(
                type: .dictionary([expectedPrompt: true])
            )
        )

        try sut.deleteDerivedData(deleteAll: true)
    }
}


// MARK: - Select Option Flow Tests
extension DerivedDataControllerTests {
    @Test("Shows option selection when delete all flag false")
    func showsOptionSelectionWhenDeleteAllFlagFalse() throws {
        let (sut, _, _) = makeSUT(
            permissionResult: .init(type: .ordered([true])),
            selectionResult: .init(
                singleSelectionType: .ordered([0])
            )
        )

        try sut.deleteDerivedData(deleteAll: false)
    }

    @Test("Throws error when user cancels option selection")
    func throwsErrorWhenUserCancelsOptionSelection() throws {
        let (sut, _, _) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([nil])
            )
        )

        #expect(throws: SwiftPickerError.selectionCancelled) {
            try sut.deleteDerivedData(deleteAll: false)
        }
    }

    @Test("Deletes all when user selects delete all option")
    func deletesAllWhenUserSelectsDeleteAllOption() throws {
        let deleteAllIndex = 0
        let (sut, service, _) = makeSUT(
            permissionResult: .init(type: .ordered([true])),
            selectionResult: .init(
                singleSelectionType: .ordered([deleteAllIndex])
            )
        )

        try sut.deleteDerivedData(deleteAll: false)

        #expect(service.didDeleteAllDerivedData)
    }

    @Test("Shows folder selection when user selects select folders option")
    func showsFolderSelectionWhenUserSelectsSelectFoldersOption() throws {
        let selectFoldersIndex = 1
        let folders = [
            makePurgeFolder(name: "Folder1"),
            makePurgeFolder(name: "Folder2")
        ]
        let (sut, service, _) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([selectFoldersIndex]),
                multiSelectionType: .ordered([[0]])
            ),
            foldersToLoad: folders
        )

        try sut.deleteDerivedData(deleteAll: false)

        #expect(service.deletedFolders.count == 1)
        #expect(service.deletedFolders.first?.name == folders[0].name)
    }
}


// MARK: - Select Folders Flow Tests
extension DerivedDataControllerTests {
    @Test("Deletes selected folders when user makes selection")
    func deletesSelectedFoldersWhenUserMakesSelection() throws {
        let folder1 = makePurgeFolder(name: "Folder1")
        let folder2 = makePurgeFolder(name: "Folder2")
        let folder3 = makePurgeFolder(name: "Folder3")
        let folders = [folder1, folder2, folder3]
        let selectedIndices = [0, 2]
        let (sut, service, _) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([1]),
                multiSelectionType: .ordered([selectedIndices])
            ),
            foldersToLoad: folders
        )

        try sut.deleteDerivedData(deleteAll: false)

        #expect(service.deletedFolders.count == 2)
        #expect(service.deletedFolders.contains(where: { $0.name == folder1.name }))
        #expect(service.deletedFolders.contains(where: { $0.name == folder3.name }))
    }

    @Test("Deletes no folders when user selects none")
    func deletesNoFoldersWhenUserSelectsNone() throws {
        let folders = [
            makePurgeFolder(name: "Folder1"),
            makePurgeFolder(name: "Folder2")
        ]
        let (sut, service, _) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([1]),
                multiSelectionType: .ordered([[]])
            ),
            foldersToLoad: folders
        )

        try sut.deleteDerivedData(deleteAll: false)

        #expect(service.deletedFolders.isEmpty)
    }

    @Test("Shows multi selection with correct prompt and folders")
    func showsMultiSelectionWithCorrectPromptAndFolders() throws {
        let expectedPrompt = "Select the folders to delete."
        let folders = [
            makePurgeFolder(name: "Folder1"),
            makePurgeFolder(name: "Folder2")
        ]
        let (sut, _, _) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([1]),
                multiSelectionType: .dictionary([expectedPrompt: [0]])
            ),
            foldersToLoad: folders
        )

        try sut.deleteDerivedData(deleteAll: false)
    }
}


// MARK: - Error Handling Tests
extension DerivedDataControllerTests {
    @Test("Propagates delete all error from service")
    func propagatesDeleteAllErrorFromService() throws {
        let (sut, _, _) = makeSUT(
            permissionResult: .init(type: .ordered([true])),
            throwError: true
        )

        #expect(throws: NSError.self) {
            try sut.deleteDerivedData(deleteAll: true)
        }
    }

    @Test("Propagates delete folders error from service")
    func propagatesDeleteFoldersErrorFromService() throws {
        let folders = [makePurgeFolder(name: "Folder1")]
        let (sut, _, _) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([1]),
                multiSelectionType: .ordered([[0]])
            ),
            throwError: true,
            foldersToLoad: folders
        )

        #expect(throws: NSError.self) {
            try sut.deleteDerivedData(deleteAll: false)
        }
    }
}


// MARK: - Path Viewing Tests
extension DerivedDataControllerTests {
    @Test("Returns default path message when no custom path is set")
    func returnsDefaultPathMessageWhenNoCustomPathIsSet() {
        let (sut, _, store) = makeSUT()

        let message = sut.managePath(set: nil as String?, reset: false)

        #expect(message.contains("Library/Developer/Xcode/DerivedData"))
        #expect(message.contains("(using default)"))
        #expect(store.string(forKey: "derivedDataPathKey") == nil)
    }

    @Test("Returns custom path message when custom path is set")
    func returnsCustomPathMessageWhenCustomPathIsSet() {
        let customPath = "/custom/path/to/derived/data"
        let (sut, _, store) = makeSUT()
        store.set(customPath, forKey: "derivedDataPathKey")

        let message = sut.managePath(set: nil as String?, reset: false)

        #expect(message.contains(customPath))
        #expect(!message.contains("(using default)"))
    }
}


// MARK: - Path Setting Tests
extension DerivedDataControllerTests {
    @Test("Sets new path and returns confirmation message")
    func setsNewPathAndReturnsConfirmationMessage() {
        let newPath = "/new/custom/path"
        let (sut, _, store) = makeSUT()

        let message = sut.managePath(set: newPath, reset: false)

        #expect(message.contains("Derived data path set to"))
        #expect(message.contains(newPath))
        #expect(store.string(forKey: "derivedDataPathKey") == newPath)
    }

    @Test("Expands tilde in path when setting new path")
    func expandsTildeInPathWhenSettingNewPath() {
        let pathWithTilde = "~/custom/derived/data"
        let (sut, _, store) = makeSUT()

        let message = sut.managePath(set: pathWithTilde, reset: false)

        let storedPath = store.string(forKey: "derivedDataPathKey")
        #expect(storedPath != nil)
        #expect(!storedPath!.contains("~"))
        #expect(message.contains(storedPath!))
    }
}


// MARK: - Path Reset Tests
extension DerivedDataControllerTests {
    @Test("Resets to default path and returns confirmation message")
    func resetsToDefaultPathAndReturnsConfirmationMessage() {
        let customPath = "/custom/path"
        let (sut, _, store) = makeSUT()
        store.set(customPath, forKey: "derivedDataPathKey")

        let message = sut.managePath(set: nil as String?, reset: true)

        #expect(message.contains("Derived data path reset to default"))
        #expect(message.contains("~/Library/Developer/Xcode/DerivedData"))
        #expect(store.string(forKey: "derivedDataPathKey") == nil)
    }

    @Test("Clears custom path from store when reset")
    func clearsCustomPathFromStoreWhenReset() {
        let customPath = "/custom/path"
        let (sut, _, store) = makeSUT()
        store.set(customPath, forKey: "derivedDataPathKey")
        #expect(store.string(forKey: "derivedDataPathKey") != nil)

        _ = sut.managePath(set: nil as String?, reset: true)

        #expect(store.string(forKey: "derivedDataPathKey") == nil)
    }
}


// MARK: - SUT
private extension DerivedDataControllerTests {
    func makeSUT(
        inputResult: MockInputResult = .init(),
        permissionResult: MockPermissionResult = .init(),
        selectionResult: MockSelectionResult = .init(),
        throwError: Bool = false,
        foldersToLoad: [PurgeFolder] = []
    ) -> (sut: DerivedDataController, service: MockDerivedDataService, store: MockUserDefaults) {
        let store = MockUserDefaults()
        let picker = MockSwiftPicker(inputResult: inputResult, permissionResult: permissionResult, selectionResult: selectionResult)
        let service = MockDerivedDataService(throwError: throwError, foldersToLoad: foldersToLoad)
        let sut = DerivedDataController(store: store, picker: picker, service: service)

        return (sut, service, store)
    }
}
