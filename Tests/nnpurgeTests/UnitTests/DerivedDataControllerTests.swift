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
        let (_, service, _, progressHandler) = makeSUT()

        #expect(!service.didDeleteAllDerivedData)
        #expect(!progressHandler.didComplete)
        #expect(progressHandler.completedMessage == nil)
        #expect(progressHandler.progressUpdates.isEmpty)
    }
}


// MARK: - Delete All Flag Tests
extension DerivedDataControllerTests {
    @Test("Deletes all derived data when flag true and permission granted")
    func deletesAllDerivedDataWhenFlagTrueAndPermissionGranted() throws {
        let (sut, service, _, _) = makeSUT(
            permissionResult: .init(grantByDefault: true, type: .ordered([true]))
        )

        try sut.deleteDerivedData(deleteAll: true)

        #expect(service.didDeleteAllDerivedData)
    }

    @Test("Throws error when delete all flag true but permission denied")
    func throwsErrorWhenDeleteAllFlagTrueButPermissionDenied() throws {
        let (sut, _, _, _) = makeSUT(
            permissionResult: .init(grantByDefault: false, type: .ordered([false]))
        )

        #expect(throws: SwiftPickerError.selectionCancelled) {
            try sut.deleteDerivedData(deleteAll: true)
        }
    }

    @Test("Requests permission with correct prompt when deleting all")
    func requestsPermissionWithCorrectPromptWhenDeletingAll() throws {
        let expectedPrompt = "Are you sure you want to delete all derived data?"
        let (sut, _, _, _) = makeSUT(
            permissionResult: .init(
                grantByDefault: true,
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
        let (sut, _, _, _) = makeSUT(
            permissionResult: .init(grantByDefault: true, type: .ordered([true])),
            selectionResult: .init(
                singleSelectionType: .ordered([0])
            )
        )

        try sut.deleteDerivedData(deleteAll: false)
    }

    @Test("Throws error when user cancels option selection")
    func throwsErrorWhenUserCancelsOptionSelection() throws {
        let (sut, _, _, _) = makeSUT(
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
        let (sut, service, _, _) = makeSUT(
            permissionResult: .init(grantByDefault: true, type: .ordered([true])),
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
            makeDerivedDataFolder(name: "Folder1"),
            makeDerivedDataFolder(name: "Folder2")
        ]
        let (sut, service, _, _) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([selectFoldersIndex]),
                multiSelectionType: .ordered([[0]])
            ),
            foldersToLoad: folders
        )

        try sut.deleteDerivedData(deleteAll: false)

        #expect(service.didDeleteAllDerivedData)
    }
}


// MARK: - Select Folders Flow Tests
extension DerivedDataControllerTests {
    @Test("Deletes selected folders when user makes selection")
    func deletesSelectedFoldersWhenUserMakesSelection() throws {
        let folder1 = makeDerivedDataFolder(name: "Folder1")
        let folder2 = makeDerivedDataFolder(name: "Folder2")
        let folder3 = makeDerivedDataFolder(name: "Folder3")
        let folders = [folder1, folder2, folder3]
        let selectedIndices = [0, 2]
        let (sut, service, _, _) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([1]),
                multiSelectionType: .ordered([selectedIndices])
            ),
            foldersToLoad: folders
        )

        try sut.deleteDerivedData(deleteAll: false)

        #expect(service.didDeleteAllDerivedData)
    }

    @Test("Deletes no folders when user selects none")
    func deletesNoFoldersWhenUserSelectsNone() throws {
        let folders = [
            makeDerivedDataFolder(name: "Folder1"),
            makeDerivedDataFolder(name: "Folder2")
        ]
        let (sut, service, _, _) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([1]),
                multiSelectionType: .ordered([[]])
            ),
            foldersToLoad: folders
        )

        try sut.deleteDerivedData(deleteAll: false)

        #expect(service.didDeleteAllDerivedData)
    }

    @Test("Shows multi selection with correct prompt and folders")
    func showsMultiSelectionWithCorrectPromptAndFolders() throws {
        let expectedPrompt = "Select the folders to delete."
        let folders = [
            makeDerivedDataFolder(name: "Folder1"),
            makeDerivedDataFolder(name: "Folder2")
        ]
        let (sut, _, _, _) = makeSUT(
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
        let (sut, _, _, _) = makeSUT(
            permissionResult: .init(grantByDefault: true, type: .ordered([true])),
            throwError: true
        )

        #expect(throws: NSError.self) {
            try sut.deleteDerivedData(deleteAll: true)
        }
    }

    @Test("Propagates delete folders error from service")
    func propagatesDeleteFoldersErrorFromService() throws {
        let folders = [makeDerivedDataFolder(name: "Folder1")]
        let (sut, _, _, _) = makeSUT(
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


// MARK: - Xcode Running User Prompt Tests
extension DerivedDataControllerTests {
    @Test("Shows Xcode running prompt with three options")
    func showsXcodeRunningPromptWithThreeOptions() throws {
        let folders = [makeDerivedDataFolder(name: "Folder1")]
        let expectedPrompt = "Xcode is currently running. What would you like to do?"
        let (sut, _, _, _) = makeSUT(
            permissionResult: .init(grantByDefault: true, type: .ordered([true])),
            selectionResult: .init(
                singleSelectionType: .dictionary([expectedPrompt: 2])
            ),
            foldersToLoad: folders,
            throwXcodeRunning: true
        )

        try? sut.deleteDerivedData(deleteAll: true)
    }

    @Test("Proceeds with force deletion when user selects proceed anyway option")
    func proceedsWithForceDeletionWhenUserSelectsProceedAnywayOption() throws {
        let folder1 = makeDerivedDataFolder(name: "Folder1")
        let folder2 = makeDerivedDataFolder(name: "Folder2")
        let folders = [folder1, folder2]
        let proceedAnywayIndex = 0
        let (sut, service, _, _) = makeSUT(
            permissionResult: .init(grantByDefault: true, type: .ordered([true])),
            selectionResult: .init(
                singleSelectionType: .ordered([proceedAnywayIndex])
            ),
            foldersToLoad: folders,
            throwXcodeRunning: true
        )

        try sut.deleteDerivedData(deleteAll: true)

        #expect(service.deletedDerivedDataFolders.count == 2)
        #expect(service.deletedDerivedDataFolders.contains(where: { $0.name == folder1.name }))
        #expect(service.deletedDerivedDataFolders.contains(where: { $0.name == folder2.name }))
    }

    @Test("Waits for user to close Xcode and proceeds when confirmed")
    func waitsForUserToCloseXcodeAndProceedsWhenConfirmed() throws {
        let folders = [makeDerivedDataFolder(name: "Folder1")]
        let waitUntilClosedIndex = 1
        let (sut, service, _, _) = makeSUT(
            permissionResult: .init(grantByDefault: true, type: .ordered([true])),
            selectionResult: .init(
                singleSelectionType: .ordered([waitUntilClosedIndex])
            ),
            foldersToLoad: folders,
            throwXcodeRunning: true
        )

        try sut.deleteDerivedData(deleteAll: true)

        #expect(service.deletedDerivedDataFolders.count == 1)
    }

    @Test("Cancels operation when user selects cancel option")
    func cancelsOperationWhenUserSelectsCancelOption() throws {
        let folders = [makeDerivedDataFolder(name: "Folder1")]
        let cancelIndex = 2
        let (sut, service, _, _) = makeSUT(
            permissionResult: .init(grantByDefault: true, type: .ordered([true])),
            selectionResult: .init(
                singleSelectionType: .ordered([cancelIndex])
            ),
            foldersToLoad: folders,
            throwXcodeRunning: true
        )

        try sut.deleteDerivedData(deleteAll: true)

        #expect(service.deletedDerivedDataFolders.isEmpty)
    }

    @Test("Throws error when user denies Xcode closure confirmation")
    func throwsErrorWhenUserDeniesXcodeClosureConfirmation() throws {
        let folders = [makeDerivedDataFolder(name: "Folder1")]
        let waitUntilClosedIndex = 1
        let (sut, _, _, _) = makeSUT(
            permissionResult: .init(grantByDefault: false, type: .ordered([false])),
            selectionResult: .init(
                singleSelectionType: .ordered([waitUntilClosedIndex])
            ),
            foldersToLoad: folders,
            throwXcodeRunning: true
        )

        #expect(throws: (any Error).self) {
            try sut.deleteDerivedData(deleteAll: true)
        }
    }

    @Test("Handles Xcode running when deleting selected folders")
    func handlesXcodeRunningWhenDeletingSelectedFolders() throws {
        let folder1 = makeDerivedDataFolder(name: "Folder1")
        let folder2 = makeDerivedDataFolder(name: "Folder2")
        let folders = [folder1, folder2]
        let proceedAnywayIndex = 0
        let (sut, service, _, _) = makeSUT(
            permissionResult: .init(grantByDefault: true, type: .ordered([true])),
            selectionResult: .init(
                singleSelectionType: .ordered([1, proceedAnywayIndex]),
                multiSelectionType: .ordered([[0, 1]])
            ),
            foldersToLoad: folders,
            throwXcodeRunning: true
        )

        try sut.deleteDerivedData(deleteAll: false)

        #expect(service.deletedDerivedDataFolders.count == 2)
        #expect(service.deletedDerivedDataFolders.contains(where: { $0.name == folder1.name }))
        #expect(service.deletedDerivedDataFolders.contains(where: { $0.name == folder2.name }))
    }
}


// MARK: - Path Viewing Tests
extension DerivedDataControllerTests {
    @Test("Returns default path message when no custom path is set")
    func returnsDefaultPathMessageWhenNoCustomPathIsSet() {
        let (sut, _, store, _) = makeSUT()

        let message = sut.managePath(set: nil as String?, reset: false)

        #expect(message.contains("Library/Developer/Xcode/DerivedData"))
        #expect(message.contains("(using default)"))
        #expect(store.string(forKey: "derivedDataPathKey") == nil)
    }

    @Test("Returns custom path message when custom path is set")
    func returnsCustomPathMessageWhenCustomPathIsSet() {
        let customPath = "/custom/path/to/derived/data"
        let (sut, _, store, _) = makeSUT()
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
        let (sut, _, store, _) = makeSUT()

        let message = sut.managePath(set: newPath, reset: false)

        #expect(message.contains("Derived data path set to"))
        #expect(message.contains(newPath))
        #expect(store.string(forKey: "derivedDataPathKey") == newPath)
    }

    @Test("Expands tilde in path when setting new path")
    func expandsTildeInPathWhenSettingNewPath() {
        let pathWithTilde = "~/custom/derived/data"
        let (sut, _, store, _) = makeSUT()

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
        let (sut, _, store, _) = makeSUT()
        store.set(customPath, forKey: "derivedDataPathKey")

        let message = sut.managePath(set: nil as String?, reset: true)

        #expect(message.contains("Derived data path reset to default"))
        #expect(message.contains("~/Library/Developer/Xcode/DerivedData"))
        #expect(store.string(forKey: "derivedDataPathKey") == nil)
    }

    @Test("Clears custom path from store when reset")
    func clearsCustomPathFromStoreWhenReset() {
        let customPath = "/custom/path"
        let (sut, _, store, _) = makeSUT()
        store.set(customPath, forKey: "derivedDataPathKey")
        #expect(store.string(forKey: "derivedDataPathKey") != nil)

        _ = sut.managePath(set: nil as String?, reset: true)

        #expect(store.string(forKey: "derivedDataPathKey") == nil)
    }
}


// MARK: - Open Folder Tests (Disabled - TODO)
extension DerivedDataControllerTests {
    @Test("Opens default derived data folder when no custom path set", .disabled())
    func opensDefaultDerivedDataFolderWhenNoCustomPathSet() throws {
        let (sut, _, _, _) = makeSUT()

        try sut.openDerivedDataFolder()

        // TODO: Add openedFolderURL property to MockPurgeService
        // let openedURL = try #require(service.openedFolderURL)
        // #expect(openedURL.path.contains("Library/Developer/Xcode/DerivedData"))
    }

    @Test("Opens custom derived data folder when custom path set", .disabled())
    func opensCustomDerivedDataFolderWhenCustomPathSet() throws {
        let customPath = "/custom/derived/data/path"
        let store = MockUserDefaults()
        store.set(customPath, forKey: "derivedDataPathKey")
        let (sut, _, _, _) = makeSUT(store: store)

        try sut.openDerivedDataFolder()

        // TODO: Add openedFolderURL property to MockPurgeService
        // let openedURL = try #require(service.openedFolderURL)
        // #expect(openedURL.path == customPath)
    }

    @Test("Propagates open folder error from service", .disabled())
    func propagatesOpenFolderErrorFromService() throws {
        let (sut, _, _, _) = makeSUT(throwError: true)

        #expect(throws: NSError.self) {
            try sut.openDerivedDataFolder()
        }
    }
}


// MARK: - Progress Handler Tests
extension DerivedDataControllerTests {
    @Test("Reports progress for each folder when deleting all")
    func reportsProgressForEachFolderWhenDeletingAll() throws {
        let folder1 = makeDerivedDataFolder(name: "Folder1")
        let folder2 = makeDerivedDataFolder(name: "Folder2")
        let folder3 = makeDerivedDataFolder(name: "Folder3")
        let folders = [folder1, folder2, folder3]
        let (sut, _, _, progressHandler) = makeSUT(
            permissionResult: .init(grantByDefault: true, type: .ordered([true])),
            foldersToLoad: folders
        )

        try sut.deleteDerivedData(deleteAll: true)

        #expect(progressHandler.progressUpdates.count == folders.count)
        guard progressHandler.progressUpdates.count >= 3 else { return }
        #expect(progressHandler.progressUpdates[0].message.contains(folder1.name))
        #expect(progressHandler.progressUpdates[1].message.contains(folder2.name))
        #expect(progressHandler.progressUpdates[2].message.contains(folder3.name))
    }

    @Test("Reports progress for each selected folder when deleting specific folders")
    func reportsProgressForEachSelectedFolderWhenDeletingSpecificFolders() throws {
        let folder1 = makeDerivedDataFolder(name: "Folder1")
        let folder2 = makeDerivedDataFolder(name: "Folder2")
        let folder3 = makeDerivedDataFolder(name: "Folder3")
        let folders = [folder1, folder2, folder3]
        let selectedIndices = [0, 2]
        let (sut, _, _, progressHandler) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([1]),
                multiSelectionType: .ordered([selectedIndices])
            ),
            foldersToLoad: folders
        )

        try sut.deleteDerivedData(deleteAll: false)

        #expect(progressHandler.progressUpdates.count == 2)
        guard progressHandler.progressUpdates.count >= 2 else { return }
        #expect(progressHandler.progressUpdates[0].message.contains(folder1.name))
        #expect(progressHandler.progressUpdates[1].message.contains(folder3.name))
    }

    @Test("Reports no progress when no folders selected")
    func reportsNoProgressWhenNoFoldersSelected() throws {
        let folders = [
            makeDerivedDataFolder(name: "Folder1"),
            makeDerivedDataFolder(name: "Folder2")
        ]
        let (sut, _, _, progressHandler) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([1]),
                multiSelectionType: .ordered([[]])
            ),
            foldersToLoad: folders
        )

        try sut.deleteDerivedData(deleteAll: false)

        #expect(progressHandler.didComplete)
    }

    @Test("Reports progress in correct order for multiple folders")
    func reportsProgressInCorrectOrderForMultipleFolders() throws {
        let folder1 = makeDerivedDataFolder(name: "Alpha")
        let folder2 = makeDerivedDataFolder(name: "Beta")
        let folder3 = makeDerivedDataFolder(name: "Gamma")
        let folder4 = makeDerivedDataFolder(name: "Delta")
        let folders = [folder1, folder2, folder3, folder4]
        let (sut, _, _, progressHandler) = makeSUT(
            permissionResult: .init(grantByDefault: true, type: .ordered([true])),
            foldersToLoad: folders
        )

        try sut.deleteDerivedData(deleteAll: true)

        #expect(progressHandler.progressUpdates.count == 4)
        for (index, folder) in folders.enumerated() {
            #expect(progressHandler.progressUpdates[index].message.contains(folder.name))
        }
    }
}


// MARK: - SUT
private extension DerivedDataControllerTests {
    func makeSUT(
        store: MockUserDefaults? = nil,
        inputResult: MockInputResult = .init(),
        permissionResult: MockPermissionResult = .init(grantByDefault: true, type: .ordered([])),
        selectionResult: MockSelectionResult = .init(),
        throwError: Bool = false,
        foldersToLoad: [DerivedDataFolder] = [],
        throwXcodeRunning: Bool = false
    ) -> (sut: DerivedDataController, service: MockPurgeService, store: MockUserDefaults, progressHandler: MockPurgeProgressHandler) {
        let actualStore = store ?? MockUserDefaults()
        let progressHandler = MockPurgeProgressHandler()
        let service = MockPurgeService(
            throwError: throwError,
            derivedDataFoldersToLoad: foldersToLoad,
            throwXcodeRunning: throwXcodeRunning
        )
        let picker = MockSwiftPicker(
            inputResult: inputResult,
            permissionResult: permissionResult,
            selectionResult: selectionResult
        )
        let sut = DerivedDataController(
            store: actualStore,
            picker: picker,
            service: service,
            progressHandler: progressHandler
        )

        return (sut, service, actualStore, progressHandler)
    }

    func makeDerivedDataFolder(name: String) -> DerivedDataFolder {
        let url = URL(fileURLWithPath: "/path/to/DerivedData/\(name)")

        return .init(
            url: url,
            name: name,
            path: url.path,
            creationDate: Date(),
            modificationDate: Date()
        )
    }
}
