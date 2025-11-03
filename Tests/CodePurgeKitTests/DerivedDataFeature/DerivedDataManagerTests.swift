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
        #expect(delegate.loadFoldersCallCount == 0)
        #expect(delegate.lastPathLoaded == nil)
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
        let (sut, delegate) = makeSUT(path: expectedPath, foldersToLoad: folders)

        let loadedFolders = try sut.loadFolders()

        #expect(delegate.loadFoldersCallCount == 1)
        #expect(delegate.lastPathLoaded == expectedPath)
        #expect(loadedFolders.count == folders.count)
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

        #expect(delegate.loadFoldersCallCount == 1)
        #expect(delegate.deletedFolders.count == folders.count)
        #expect(delegate.deletedFolders.contains(where: { $0.name == folder1.name }))
        #expect(delegate.deletedFolders.contains(where: { $0.name == folder2.name }))
        #expect(delegate.deletedFolders.contains(where: { $0.name == folder3.name }))
    }

    @Test("Deletes no folders when none exist")
    func deletesNoFoldersWhenNoneExist() throws {
        let (sut, delegate) = makeSUT(foldersToLoad: [])

        try sut.deleteAllDerivedData()

        #expect(delegate.loadFoldersCallCount == 1)
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
        #expect(delegate.deletedFolders[0].name == folder1.name)
        #expect(delegate.deletedFolders[1].name == folder2.name)
    }

    @Test("Deletes single folder successfully")
    func deletesSingleFolderSuccessfully() throws {
        let folder = makePurgeFolder(name: "SingleFolder")
        let (sut, delegate) = makeSUT()

        try sut.deleteFolders([folder])

        #expect(delegate.deletedFolders.count == 1)
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
        let (sut, delegate) = makeSUT(path: customPath)

        _ = try sut.loadFolders()

        #expect(delegate.lastPathLoaded == customPath)
    }

    @Test("Deletes all folders from custom path location")
    func deletesAllFoldersFromCustomPathLocation() throws {
        let customPath = "/custom/path/DerivedData"
        let folder = makePurgeFolder(name: "CustomPathFolder")
        let (sut, delegate) = makeSUT(path: customPath, foldersToLoad: [folder])

        try sut.deleteAllDerivedData()

        #expect(delegate.lastPathLoaded == customPath)
        #expect(delegate.deletedFolders.count == 1)
        #expect(delegate.deletedFolders[0].name == folder.name)
    }
}


// MARK: - SUT
private extension DerivedDataManagerTests {
    func makeSUT(
        path: String = "/default/path",
        throwError: Bool = false,
        foldersToLoad: [PurgeFolder] = []
    ) -> (sut: DerivedDataManager, delegate: MockDerivedDataDelegate) {
        let delegate = MockDerivedDataDelegate(throwError: throwError, foldersToLoad: foldersToLoad)
        let sut = DerivedDataManager(path: path, delegate: delegate)

        return (sut, delegate)
    }
}
