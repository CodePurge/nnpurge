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
        let (_, _, delegate) = makeSUT()

        #expect(delegate.deletedFolders.isEmpty)
    }
}


// MARK: - Load Folders Tests
extension DerivedDataManagerTests {
    @Test("Loads folders from specified path using loader")
    func loadsFoldersFromSpecifiedPathUsingLoader() throws {
        let expectedPath = "/custom/derived/data/path"
        let folders = [
            makePurgeFolder(name: "Folder1"),
            makePurgeFolder(name: "Folder2")
        ]
        let (sut, loader, _) = makeSUT(path: expectedPath, foldersToLoad: folders)

        let loadedFolders = try sut.loadFolders()

        #expect(loader.loadedPath == expectedPath)
        #expect(loadedFolders.count == folders.count)
        guard loadedFolders.count >= 2 else { return }
        #expect(loadedFolders[0].name == folders[0].name)
        #expect(loadedFolders[1].name == folders[1].name)
    }

    @Test("Returns empty array when no folders available")
    func returnsEmptyArrayWhenNoFoldersAvailable() throws {
        let (sut, _, _) = makeSUT(foldersToLoad: [])

        let loadedFolders = try sut.loadFolders()

        #expect(loadedFolders.isEmpty)
    }

    @Test("Propagates load folders error from loader")
    func propagatesLoadFoldersErrorFromLoader() throws {
        let (sut, _, _) = makeSUT(throwError: true)

        #expect(throws: NSError.self) {
            try sut.loadFolders()
        }
    }
}


// MARK: - Delete Derived Data Tests
extension DerivedDataManagerTests {
    @Test("Deletes loaded folders using delegate")
    func deletesLoadedFoldersUsingDelegate() throws {
        let folder1 = makePurgeFolder(name: "Folder1")
        let folder2 = makePurgeFolder(name: "Folder2")
        let folder3 = makePurgeFolder(name: "Folder3")
        let folders = [folder1, folder2, folder3]
        let (sut, _, delegate) = makeSUT(foldersToLoad: folders)

        let loadedFolders = try sut.loadFolders()
        try sut.deleteDerivedData(loadedFolders, progressHandler: nil)

        #expect(delegate.deletedFolders.count == folders.count)
        #expect(delegate.deletedFolders.contains(where: { $0.name == folder1.name }))
        #expect(delegate.deletedFolders.contains(where: { $0.name == folder2.name }))
        #expect(delegate.deletedFolders.contains(where: { $0.name == folder3.name }))
    }

    @Test("Deletes no folders when given empty array")
    func deletesNoFoldersWhenGivenEmptyArray() throws {
        let (sut, _, delegate) = makeSUT(foldersToLoad: [])

        try sut.deleteDerivedData([], progressHandler: nil)

        #expect(delegate.deletedFolders.isEmpty)
    }
}


// MARK: - Delete Specific Folders Tests
extension DerivedDataManagerTests {
    @Test("Deletes specified folders in correct order")
    func deletesSpecifiedFoldersInCorrectOrder() throws {
        let folder1 = makeDerivedDataFolder(name: "Folder1")
        let folder2 = makeDerivedDataFolder(name: "Folder2")
        let foldersToDelete = [folder1, folder2]
        let (sut, _, delegate) = makeSUT()

        try sut.deleteDerivedData(foldersToDelete, progressHandler: nil)

        #expect(delegate.deletedFolders.count == 2)
        guard delegate.deletedFolders.count >= 2 else { return }
        #expect(delegate.deletedFolders[0].name == folder1.name)
        #expect(delegate.deletedFolders[1].name == folder2.name)
    }

    @Test("Deletes single folder successfully")
    func deletesSingleFolderSuccessfully() throws {
        let folder = makeDerivedDataFolder(name: "SingleFolder")
        let (sut, _, delegate) = makeSUT()

        try sut.deleteDerivedData([folder], progressHandler: nil)

        #expect(delegate.deletedFolders.count == 1)
        guard delegate.deletedFolders.count >= 1 else { return }
        #expect(delegate.deletedFolders[0].name == folder.name)
    }

    @Test("Completes successfully when given empty folder list")
    func completesSuccessfullyWhenGivenEmptyFolderList() throws {
        let (sut, _, delegate) = makeSUT()

        try sut.deleteDerivedData([], progressHandler: nil)

        #expect(delegate.deletedFolders.isEmpty)
    }

    @Test("Propagates deletion error from delegate")
    func propagatesDeletionErrorFromDelegate() throws {
        let folder = makeDerivedDataFolder(name: "ErrorFolder")
        let (sut, _, _) = makeSUT(throwError: true)

        #expect(throws: NSError.self) {
            try sut.deleteDerivedData([folder], progressHandler: nil)
        }
    }

    @Test("Stops deletion on first error and does not continue")
    func stopsDeletionOnFirstErrorAndDoesNotContinue() throws {
        let folder1 = makeDerivedDataFolder(name: "Folder1")
        let folder2 = makeDerivedDataFolder(name: "Folder2")
        let (sut, _, delegate) = makeSUT(throwError: true)

        #expect(throws: NSError.self) {
            try sut.deleteDerivedData([folder1, folder2], progressHandler: nil)
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
        let (sut, loader, _) = makeSUT(path: customPath, foldersToLoad: [folder])

        let loadedFolders = try sut.loadFolders()

        #expect(loader.loadedPath == customPath)
        #expect(loadedFolders.count == 1)
    }

    @Test("Deletes folders from custom path location")
    func deletesFoldersFromCustomPathLocation() throws {
        let customPath = "/custom/path/DerivedData"
        let folder = makePurgeFolder(name: "CustomPathFolder")
        let (sut, _, delegate) = makeSUT(path: customPath, foldersToLoad: [folder])

        let loadedFolders = try sut.loadFolders()
        try sut.deleteDerivedData(loadedFolders, progressHandler: nil)

        #expect(delegate.deletedFolders.count == 1)
        guard delegate.deletedFolders.count >= 1 else { return }
        #expect(delegate.deletedFolders[0].name == folder.name)
    }
}


// MARK: - Progress Handler Tests
extension DerivedDataManagerTests {
    @Test("Calls progress handler for each folder when deleting")
    func callsProgressHandlerForEachFolderWhenDeleting() throws {
        let folder1 = makeDerivedDataFolder(name: "Folder1")
        let folder2 = makeDerivedDataFolder(name: "Folder2")
        let folder3 = makeDerivedDataFolder(name: "Folder3")
        let folders = [folder1, folder2, folder3]
        let progressHandler = MockPurgeProgressHandler()
        let (sut, _, _) = makeSUT()

        try sut.deleteDerivedData(folders, progressHandler: progressHandler)

        #expect(progressHandler.progressUpdates.count == folders.count)
        guard progressHandler.progressUpdates.count >= 3 else { return }
        #expect(progressHandler.progressUpdates[0].message.contains(folder1.name))
        #expect(progressHandler.progressUpdates[1].message.contains(folder2.name))
        #expect(progressHandler.progressUpdates[2].message.contains(folder3.name))
    }

    @Test("Calls progress handler for each specified folder")
    func callsProgressHandlerForEachSpecifiedFolder() throws {
        let folder1 = makeDerivedDataFolder(name: "Alpha")
        let folder2 = makeDerivedDataFolder(name: "Beta")
        let folder3 = makeDerivedDataFolder(name: "Gamma")
        let foldersToDelete = [folder1, folder2, folder3]
        let progressHandler = MockPurgeProgressHandler()
        let (sut, _, _) = makeSUT()

        try sut.deleteDerivedData(foldersToDelete, progressHandler: progressHandler)

        #expect(progressHandler.progressUpdates.count == 3)
        guard progressHandler.progressUpdates.count >= 3 else { return }
        #expect(progressHandler.progressUpdates[0].message.contains(folder1.name))
        #expect(progressHandler.progressUpdates[1].message.contains(folder2.name))
        #expect(progressHandler.progressUpdates[2].message.contains(folder3.name))
    }

    @Test("Does not call progress handler when no folders to delete")
    func doesNotCallProgressHandlerWhenNoFoldersToDelete() throws {
        let progressHandler = MockPurgeProgressHandler()
        let (sut, _, _) = makeSUT(foldersToLoad: [])

        try sut.deleteDerivedData([], progressHandler: progressHandler)

        #expect(progressHandler.progressUpdates.isEmpty)
    }

    @Test("Calls progress handler in correct deletion order")
    func callsProgressHandlerInCorrectDeletionOrder() throws {
        let folder1 = makeDerivedDataFolder(name: "First")
        let folder2 = makeDerivedDataFolder(name: "Second")
        let folder3 = makeDerivedDataFolder(name: "Third")
        let folder4 = makeDerivedDataFolder(name: "Fourth")
        let folders = [folder1, folder2, folder3, folder4]
        let progressHandler = MockPurgeProgressHandler()
        let (sut, _, _) = makeSUT()

        try sut.deleteDerivedData(folders, progressHandler: progressHandler)

        #expect(progressHandler.progressUpdates.count == 4)
        guard progressHandler.progressUpdates.count == 4 else { return }
        for (index, folder) in folders.enumerated() {
            #expect(progressHandler.progressUpdates[index].message.contains(folder.name))
        }
    }

    @Test("Works correctly when progress handler is nil")
    func worksCorrectlyWhenProgressHandlerIsNil() throws {
        let folder = makeDerivedDataFolder(name: "TestFolder")
        let (sut, _, delegate) = makeSUT()

        try sut.deleteDerivedData([folder], progressHandler: nil as (any PurgeProgressHandler)?)

        #expect(delegate.deletedFolders.count == 1)
        guard delegate.deletedFolders.count >= 1 else { return }
        #expect(delegate.deletedFolders[0].name == folder.name)
    }

    @Test("Calls complete on progress handler after deletion")
    func callsCompleteOnProgressHandlerAfterDeletion() throws {
        let folder1 = makeDerivedDataFolder(name: "Folder1")
        let folder2 = makeDerivedDataFolder(name: "Folder2")
        let folders = [folder1, folder2]
        let progressHandler = MockPurgeProgressHandler()
        let (sut, _, _) = makeSUT()

        try sut.deleteDerivedData(folders, progressHandler: progressHandler)

        #expect(progressHandler.didComplete)
        #expect(progressHandler.completedMessage != nil)
    }
}


// MARK: - SUT
private extension DerivedDataManagerTests {
    func makeSUT(
        path: String = "/default/path",
        throwError: Bool = false,
        foldersToLoad: [any PurgeFolder] = []
    ) -> (sut: DerivedDataManager, loader: MockPurgeFolderLoader, delegate: MockDerivedDataDelegate) {
        let loader = MockPurgeFolderLoader(throwError: throwError, foldersToLoad: foldersToLoad)
        let delegate = MockDerivedDataDelegate(throwError: throwError)
        let sut = DerivedDataManager(path: path, loader: loader, delegate: delegate)

        return (sut, loader, delegate)
    }

    func makePurgeFolder(name: String = "TestFolder") -> MockPurgeFolder {
        return MockPurgeFolder(name: name)
    }

    func makeDerivedDataFolder(name: String = "TestFolder") -> DerivedDataFolder {
        let url = URL(fileURLWithPath: "/path/to/\(name)")
        return DerivedDataFolder(url: url, name: name, path: url.path, creationDate: Date(), modificationDate: Date())
    }
}


// MARK: - Mock PurgeFolder
private struct MockPurgeFolder: PurgeFolder {
    let url: URL
    let name: String
    let path: String
    let subfolders: [MockPurgeFolder] = []
    let creationDate: Date?
    let modificationDate: Date?

    init(name: String) {
        let url = URL(fileURLWithPath: "/path/to/\(name)")
        self.url = url
        self.name = name
        self.path = url.path
        self.creationDate = Date()
        self.modificationDate = Date()
    }

    func getSize() -> Int64 {
        return 1024
    }
}


// MARK: - Mock DerivedDataDelegate
private final class MockDerivedDataDelegate: DerivedDataDelegate, @unchecked Sendable {
    private let throwError: Bool

    private(set) var deletedFolders: [DerivedDataFolder] = []

    init(throwError: Bool = false) {
        self.throwError = throwError
    }

    func deleteFolder(_ folder: DerivedDataFolder) throws {
        if throwError {
            throw NSError(domain: "MockDerivedDataDelegate", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        }
        deletedFolders.append(folder)
    }
}
