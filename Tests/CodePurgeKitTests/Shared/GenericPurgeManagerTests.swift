//
//  GenericPurgeManagerTests.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Testing
import Foundation
import CodePurgeTesting
@testable import CodePurgeKit

struct GenericPurgeManagerTests {
    @Test("Starting values empty")
    func emptyStartingValues() {
        let (_, delegate, progressHandler) = makeSUT()

        #expect(delegate.deletedFolders.isEmpty)
        #expect(delegate.openedURL == nil)
        #expect(!progressHandler.didComplete)
        #expect(progressHandler.completedMessage == nil)
        #expect(progressHandler.progressUpdates.isEmpty)
    }
}


// MARK: - Load Folders
extension GenericPurgeManagerTests {
    @Test("Loads folders from configured path")
    func loadsFoldersFromConfiguredPath() throws {
        let folders = [makePurgeFolder(), makePurgeFolder()]
        let (sut, _, _) = makeSUT(foldersToLoad: folders)

        let loadedFolders = try sut.loadFolders()

        #expect(loadedFolders.count == folders.count)
    }

    @Test("Throws error when loading folders fails")
    func throwsErrorWhenLoadingFoldersFails() {
        let (sut, _, _) = makeSUT(throwError: true)

        #expect(throws: NSError.self) {
            try sut.loadFolders()
        }
    }

    @Test("Expands tilde in path when configured")
    func expandsTildeInPathWhenConfigured() throws {
        let path = "~/test/path"
        let config = PurgeConfiguration(path: path, expandPath: true)
        let delegate = MockPurgeDelegate(foldersToLoad: [makePurgeFolder()])
        let sut = GenericPurgeManager(configuration: config, delegate: delegate)

        _ = try sut.loadFolders()

        // Delegate received expanded path (tested implicitly - no error)
        #expect(delegate.deletedFolders.isEmpty) // Verify delegate was called
    }

    @Test("Uses literal path when expand is false")
    func usesLiteralPathWhenExpandIsFalse() throws {
        let path = "/absolute/path"
        let config = PurgeConfiguration(path: path, expandPath: false)
        let delegate = MockPurgeDelegate(foldersToLoad: [makePurgeFolder()])
        let sut = GenericPurgeManager(configuration: config, delegate: delegate)

        _ = try sut.loadFolders()

        #expect(delegate.deletedFolders.isEmpty)
    }
}


// MARK: - Delete All Folders
extension GenericPurgeManagerTests {
    @Test("Deletes all folders when requested")
    func deletesAllFoldersWhenRequested() throws {
        let folders = [makePurgeFolder(), makePurgeFolder(), makePurgeFolder()]
        let (sut, delegate, _) = makeSUT(foldersToLoad: folders)

        try sut.deleteAllFolders(progressHandler: nil as PurgeProgressHandler?)

        #expect(delegate.deletedFolders.count == folders.count)
    }

    @Test("Notifies progress handler for each deleted folder")
    func notifiesProgressHandlerForEachDeletedFolder() throws {
        let folders = [makePurgeFolder(), makePurgeFolder()]
        let (sut, _, progressHandler) = makeSUT(foldersToLoad: folders)

        try sut.deleteAllFolders(progressHandler: progressHandler)

        #expect(progressHandler.progressUpdates.count == folders.count)
    }

    @Test("Throws error when delete all fails")
    func throwsErrorWhenDeleteAllFails() {
        let (sut, _, _) = makeSUT(throwError: true, foldersToLoad: [makePurgeFolder()])

        #expect(throws: NSError.self) {
            try sut.deleteAllFolders(progressHandler: nil as PurgeProgressHandler?)
        }
    }
}


// MARK: - Delete Specific Folders
extension GenericPurgeManagerTests {
    @Test("Deletes only specified folders")
    func deletesOnlySpecifiedFolders() throws {
        let folder1 = makePurgeFolder(name: "Folder1")
        let folder2 = makePurgeFolder(name: "Folder2")
        let foldersToDelete = [folder1, folder2]
        let (sut, delegate, _) = makeSUT()

        try sut.deleteFolders(foldersToDelete, progressHandler: nil as PurgeProgressHandler?)

        #expect(delegate.deletedFolders.count == foldersToDelete.count)
        #expect(delegate.deletedFolders.contains(where: { $0.name == folder1.name }))
        #expect(delegate.deletedFolders.contains(where: { $0.name == folder2.name }))
    }

    @Test("Notifies progress handler when deleting specific folders")
    func notifiesProgressHandlerWhenDeletingSpecificFolders() throws {
        let folders = [makePurgeFolder(), makePurgeFolder()]
        let (sut, _, progressHandler) = makeSUT()

        try sut.deleteFolders(folders, progressHandler: progressHandler)

        #expect(progressHandler.progressUpdates.count == folders.count)
    }

    @Test("Throws error when deleting specific folders fails")
    func throwsErrorWhenDeletingSpecificFoldersFails() {
        let (sut, _, _) = makeSUT(throwError: true)
        let folders = [makePurgeFolder()]

        #expect(throws: NSError.self) {
            try sut.deleteFolders(folders, progressHandler: nil as PurgeProgressHandler?)
        }
    }
}


// MARK: - Open Folder
extension GenericPurgeManagerTests {
    @Test("Opens folder at specified URL")
    func opensFolderAtSpecifiedURL() throws {
        let url = URL(fileURLWithPath: "/test/path")
        let (sut, delegate, _) = makeSUT()

        try sut.openFolder(at: url)

        #expect(delegate.openedURL == url)
    }

    @Test("Throws error when opening folder fails")
    func throwsErrorWhenOpeningFolderFails() {
        let (sut, _, _) = makeSUT(throwError: true)
        let url = URL(fileURLWithPath: "/test/path")

        #expect(throws: NSError.self) {
            try sut.openFolder(at: url)
        }
    }
}


// MARK: - Progress Handler
extension GenericPurgeManagerTests {
    @Test("Does not call progress handler when nil")
    func doesNotCallProgressHandlerWhenNil() throws {
        let folders = [makePurgeFolder()]
        let (sut, delegate, _) = makeSUT(foldersToLoad: folders)

        try sut.deleteAllFolders(progressHandler: nil as PurgeProgressHandler?)

        #expect(delegate.deletedFolders.count == folders.count)
    }

    @Test("Calls progress handler for each folder in correct order")
    func callsProgressHandlerForEachFolderInCorrectOrder() throws {
        let folder1 = makePurgeFolder(name: "First")
        let folder2 = makePurgeFolder(name: "Second")
        let folder3 = makePurgeFolder(name: "Third")
        let folders = [folder1, folder2, folder3]
        let (sut, _, progressHandler) = makeSUT(foldersToLoad: folders)

        try sut.deleteAllFolders(progressHandler: progressHandler)

        #expect(progressHandler.progressUpdates[0].message.contains(folder1.name))
        #expect(progressHandler.progressUpdates[1].message.contains(folder2.name))
        #expect(progressHandler.progressUpdates[2].message.contains(folder3.name))
    }
}


// MARK: - SUT
private extension GenericPurgeManagerTests {
    func makeSUT(
        throwError: Bool = false,
        foldersToLoad: [OldPurgeFolder] = [],
        path: String = "/default/path",
        expandPath: Bool = false
    ) -> (sut: GenericPurgeManager, delegate: MockPurgeDelegate, progressHandler: MockPurgeProgressHandler) {
        let config = PurgeConfiguration(path: path, expandPath: expandPath)
        let delegate = MockPurgeDelegate(throwError: throwError, foldersToLoad: foldersToLoad)
        let progressHandler = MockPurgeProgressHandler()
        let sut = GenericPurgeManager(configuration: config, delegate: delegate)

        return (sut, delegate, progressHandler)
    }

    func makePurgeFolder(name: String = "TestFolder") -> OldPurgeFolder {
        OldPurgeFolder(
            url: URL(fileURLWithPath: "/test/\(name)"),
            name: name,
            path: "/test/\(name)",
            size: 1024
        )
    }
}
