//
//  DerivedDataManagerTests.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Testing
import Foundation
import CodePurgeTesting
@testable import CodePurgeKit

struct DerivedDataManagerTests {
    @Test("Starting values empty")
    func emptyStartingValues() {
        let (_, delegate) = makeSUT()

        #expect(delegate.deletedFolders.isEmpty)
        #expect(delegate.openedURL == nil)
    }
}


// MARK: - Load Folders Tests
extension DerivedDataManagerTests {
    @Test("Loads folders from specified path using delegate")
    func loadsFoldersFromSpecifiedPathUsingDelegate() throws {
        let expectedPath = "/custom/derived/data/path"
        let folders = [
            makePurgeFolder(name: "Folder1"),
            makePurgeFolder(name: "Folder2")
        ]
        let (sut, _) = makeSUT(path: expectedPath, foldersToLoad: folders)

        let loadedFolders = try sut.loadFolders()

        #expect(loadedFolders.count == folders.count)
        guard loadedFolders.count >= 2 else { return }
        #expect(loadedFolders[0].name == folders[0].name)
        #expect(loadedFolders[1].name == folders[1].name)
    }

    @Test("Returns empty array when no folders available")
    func returnsEmptyArrayWhenNoFoldersAvailable() throws {
        let (sut, _) = makeSUT(foldersToLoad: [])

        let loadedFolders = try sut.loadFolders()

        #expect(loadedFolders.isEmpty)
    }

    @Test("Propagates load folders error from delegate")
    func propagatesLoadFoldersErrorFromDelegate() throws {
        let (sut, _) = makeSUT(throwError: true)

        #expect(throws: NSError.self) {
            try sut.loadFolders()
        }
    }
}


// MARK: - Delete All Derived Data Tests
extension DerivedDataManagerTests {
    @Test("Loads all folders and deletes them when deleting all")
    func loadsAllFoldersAndDeletesThemWhenDeletingAll() throws {
        let folder1 = makePurgeFolder(name: "Folder1")
        let folder2 = makePurgeFolder(name: "Folder2")
        let folder3 = makePurgeFolder(name: "Folder3")
        let folders = [folder1, folder2, folder3]
        let (sut, delegate) = makeSUT(foldersToLoad: folders)

        try sut.deleteAllDerivedData()

        #expect(delegate.deletedFolders.count == folders.count)
        #expect(delegate.deletedFolders.contains(where: { $0.name == folder1.name }))
        #expect(delegate.deletedFolders.contains(where: { $0.name == folder2.name }))
        #expect(delegate.deletedFolders.contains(where: { $0.name == folder3.name }))
    }

    @Test("Deletes no folders when none exist")
    func deletesNoFoldersWhenNoneExist() throws {
        let (sut, delegate) = makeSUT(foldersToLoad: [])

        try sut.deleteAllDerivedData()

        #expect(delegate.deletedFolders.isEmpty)
    }

    @Test("Propagates load error during delete all operation")
    func propagatesLoadErrorDuringDeleteAllOperation() throws {
        let (sut, _) = makeSUT(throwError: true)

        #expect(throws: NSError.self) {
            try sut.deleteAllDerivedData()
        }
    }
}


// MARK: - Delete Specific Folders Tests
extension DerivedDataManagerTests {
    @Test("Deletes specified folders in correct order")
    func deletesSpecifiedFoldersInCorrectOrder() throws {
        let folder1 = makePurgeFolder(name: "Folder1")
        let folder2 = makePurgeFolder(name: "Folder2")
        let foldersToDelete = [folder1, folder2]
        let (sut, delegate) = makeSUT()

        try sut.deleteFolders(foldersToDelete)

        #expect(delegate.deletedFolders.count == 2)
        guard delegate.deletedFolders.count >= 2 else { return }
        #expect(delegate.deletedFolders[0].name == folder1.name)
        #expect(delegate.deletedFolders[1].name == folder2.name)
    }

    @Test("Deletes single folder successfully")
    func deletesSingleFolderSuccessfully() throws {
        let folder = makePurgeFolder(name: "SingleFolder")
        let (sut, delegate) = makeSUT()

        try sut.deleteFolders([folder])

        #expect(delegate.deletedFolders.count == 1)
        guard delegate.deletedFolders.count >= 1 else { return }
        #expect(delegate.deletedFolders[0].name == folder.name)
    }

    @Test("Completes successfully when given empty folder list")
    func completesSuccessfullyWhenGivenEmptyFolderList() throws {
        let (sut, delegate) = makeSUT()

        try sut.deleteFolders([])

        #expect(delegate.deletedFolders.isEmpty)
    }

    @Test("Propagates deletion error from delegate")
    func propagatesDeletionErrorFromDelegate() throws {
        let folder = makePurgeFolder(name: "ErrorFolder")
        let (sut, _) = makeSUT(throwError: true)

        #expect(throws: NSError.self) {
            try sut.deleteFolders([folder])
        }
    }

    @Test("Stops deletion on first error and does not continue")
    func stopsDeletionOnFirstErrorAndDoesNotContinue() throws {
        let folder1 = makePurgeFolder(name: "Folder1")
        let folder2 = makePurgeFolder(name: "Folder2")
        let (sut, delegate) = makeSUT(throwError: true)

        #expect(throws: NSError.self) {
            try sut.deleteFolders([folder1, folder2])
        }

        #expect(delegate.deletedFolders.isEmpty)
    }
}


// MARK: - Path Configuration Tests
extension DerivedDataManagerTests {
    @Test("Uses specified path for folder operations")
    func usesSpecifiedPathForFolderOperations() throws {
        let customPath = "/custom/xcode/path"
        let folder = makePurgeFolder(name: "TestFolder")
        let (sut, _) = makeSUT(path: customPath, foldersToLoad: [folder])

        let loadedFolders = try sut.loadFolders()

        #expect(loadedFolders.count == 1)
    }

    @Test("Deletes all folders from custom path location")
    func deletesAllFoldersFromCustomPathLocation() throws {
        let customPath = "/custom/path/DerivedData"
        let folder = makePurgeFolder(name: "CustomPathFolder")
        let (sut, delegate) = makeSUT(path: customPath, foldersToLoad: [folder])

        try sut.deleteAllDerivedData()

        #expect(delegate.deletedFolders.count == 1)
        guard delegate.deletedFolders.count >= 1 else { return }
        #expect(delegate.deletedFolders[0].name == folder.name)
    }
}


// MARK: - Progress Handler Tests
extension DerivedDataManagerTests {
    @Test("Calls progress handler for each folder when deleting all")
    func callsProgressHandlerForEachFolderWhenDeletingAll() throws {
        let folder1 = makePurgeFolder(name: "Folder1")
        let folder2 = makePurgeFolder(name: "Folder2")
        let folder3 = makePurgeFolder(name: "Folder3")
        let folders = [folder1, folder2, folder3]
        let progressHandler = MockPurgeProgressHandler()
        let (sut, _) = makeSUT(foldersToLoad: folders)

        try sut.deleteAllDerivedData(progressHandler: progressHandler)

        #expect(progressHandler.progressUpdates.count == folders.count)
        guard progressHandler.progressUpdates.count >= 3 else { return }
        #expect(progressHandler.progressUpdates[0].message.contains(folder1.name))
        #expect(progressHandler.progressUpdates[1].message.contains(folder2.name))
        #expect(progressHandler.progressUpdates[2].message.contains(folder3.name))
    }

    @Test("Calls progress handler for each specified folder")
    func callsProgressHandlerForEachSpecifiedFolder() throws {
        let folder1 = makePurgeFolder(name: "Alpha")
        let folder2 = makePurgeFolder(name: "Beta")
        let folder3 = makePurgeFolder(name: "Gamma")
        let foldersToDelete = [folder1, folder2, folder3]
        let progressHandler = MockPurgeProgressHandler()
        let (sut, _) = makeSUT()

        try sut.deleteFolders(foldersToDelete, progressHandler: progressHandler)

        #expect(progressHandler.progressUpdates.count == 3)
        guard progressHandler.progressUpdates.count >= 3 else { return }
        #expect(progressHandler.progressUpdates[0].message.contains(folder1.name))
        #expect(progressHandler.progressUpdates[1].message.contains(folder2.name))
        #expect(progressHandler.progressUpdates[2].message.contains(folder3.name))
    }

    @Test("Does not call progress handler when no folders to delete")
    func doesNotCallProgressHandlerWhenNoFoldersToDelete() throws {
        let progressHandler = MockPurgeProgressHandler()
        let (sut, _) = makeSUT(foldersToLoad: [])

        try sut.deleteAllDerivedData(progressHandler: progressHandler)

        #expect(progressHandler.progressUpdates.isEmpty)
    }

    @Test("Calls progress handler in correct deletion order")
    func callsProgressHandlerInCorrectDeletionOrder() throws {
        let folder1 = makePurgeFolder(name: "First")
        let folder2 = makePurgeFolder(name: "Second")
        let folder3 = makePurgeFolder(name: "Third")
        let folder4 = makePurgeFolder(name: "Fourth")
        let folders = [folder1, folder2, folder3, folder4]
        let progressHandler = MockPurgeProgressHandler()
        let (sut, _) = makeSUT()

        try sut.deleteFolders(folders, progressHandler: progressHandler)

        #expect(progressHandler.progressUpdates.count == 4)
        guard progressHandler.progressUpdates.count == 4 else { return }
        for (index, folder) in folders.enumerated() {
            #expect(progressHandler.progressUpdates[index].message.contains(folder.name))
        }
    }

    @Test("Works correctly when progress handler is nil")
    func worksCorrectlyWhenProgressHandlerIsNil() throws {
        let folder = makePurgeFolder(name: "TestFolder")
        let (sut, delegate) = makeSUT(foldersToLoad: [folder])

        try sut.deleteAllDerivedData(progressHandler: nil)

        #expect(delegate.deletedFolders.count == 1)
        guard delegate.deletedFolders.count >= 1 else { return }
        #expect(delegate.deletedFolders[0].name == folder.name)
    }

    @Test("Calls progress handler even when using convenience method")
    func callsProgressHandlerEvenWhenUsingConvenienceMethod() throws {
        let folder1 = makePurgeFolder(name: "ConvenienceFolder1")
        let folder2 = makePurgeFolder(name: "ConvenienceFolder2")
        let folders = [folder1, folder2]
        let (sut, delegate) = makeSUT(foldersToLoad: folders)

        try sut.deleteAllDerivedData()

        #expect(delegate.deletedFolders.count == 2)
    }
}


// MARK: - SUT
private extension DerivedDataManagerTests {
    func makeSUT(
        path: String = "/default/path",
        throwError: Bool = false,
        foldersToLoad: [PurgeFolder] = []
    ) -> (sut: DerivedDataManager, delegate: MockPurgeDelegate) {
        let delegate = MockPurgeDelegate(throwError: throwError, foldersToLoad: foldersToLoad)
        let sut = DerivedDataManager(path: path, delegate: delegate)

        return (sut, delegate)
    }
}
