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
        let (_, _, delegate, _, _) = makeSUT()

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
        let (sut, loader, _, _, _) = makeSUT(path: expectedPath, foldersToLoad: folders)

        let loadedFolders = try sut.loadFolders()

        #expect(loader.loadedPath == expectedPath)
        #expect(loadedFolders.count == folders.count)
        guard loadedFolders.count >= 2 else { return }
        #expect(loadedFolders[0].name == folders[0].name)
        #expect(loadedFolders[1].name == folders[1].name)
    }

    @Test("Returns empty array when no folders available")
    func returnsEmptyArrayWhenNoFoldersAvailable() throws {
        let (sut, _, _, _, _) = makeSUT(foldersToLoad: [])

        let loadedFolders = try sut.loadFolders()

        #expect(loadedFolders.isEmpty)
    }

    @Test("Propagates load folders error from loader")
    func propagatesLoadFoldersErrorFromLoader() throws {
        let (sut, _, _, _, _) = makeSUT(throwError: true)

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
        let (sut, _, delegate, _, _) = makeSUT(foldersToLoad: folders)

        let loadedFolders = try sut.loadFolders()
        try sut.deleteFolders(loadedFolders, force: false, progressHandler: nil)

        #expect(delegate.deletedFolders.count == folders.count)
        #expect(delegate.deletedFolders.contains(where: { $0.name == folder1.name }))
        #expect(delegate.deletedFolders.contains(where: { $0.name == folder2.name }))
        #expect(delegate.deletedFolders.contains(where: { $0.name == folder3.name }))
    }

    @Test("Deletes no folders when given empty array")
    func deletesNoFoldersWhenGivenEmptyArray() throws {
        let (sut, _, delegate, _, _) = makeSUT(foldersToLoad: [])

        try sut.deleteFolders([], force: false, progressHandler: nil)

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
        let (sut, _, delegate, _, _) = makeSUT()

        try sut.deleteFolders(foldersToDelete, force: false, progressHandler: nil)

        #expect(delegate.deletedFolders.count == 2)
        guard delegate.deletedFolders.count >= 2 else { return }
        #expect(delegate.deletedFolders[0].name == folder1.name)
        #expect(delegate.deletedFolders[1].name == folder2.name)
    }

    @Test("Deletes single folder successfully")
    func deletesSingleFolderSuccessfully() throws {
        let folder = makeDerivedDataFolder(name: "SingleFolder")
        let (sut, _, delegate, _, _) = makeSUT()

        try sut.deleteFolders([folder], force: false, progressHandler: nil)

        #expect(delegate.deletedFolders.count == 1)
        guard delegate.deletedFolders.count >= 1 else { return }
        #expect(delegate.deletedFolders[0].name == folder.name)
    }

    @Test("Completes successfully when given empty folder list")
    func completesSuccessfullyWhenGivenEmptyFolderList() throws {
        let (sut, _, delegate, _, _) = makeSUT()

        try sut.deleteFolders([], force: false, progressHandler: nil)

        #expect(delegate.deletedFolders.isEmpty)
    }

    @Test("Propagates deletion error from delegate")
    func propagatesDeletionErrorFromDelegate() throws {
        let folder = makeDerivedDataFolder(name: "ErrorFolder")
        let (sut, _, _, _, _) = makeSUT(throwError: true)

        #expect(throws: NSError.self) {
            try sut.deleteFolders([folder], force: false, progressHandler: nil)
        }
    }

    @Test("Stops deletion on first error and does not continue")
    func stopsDeletionOnFirstErrorAndDoesNotContinue() throws {
        let folder1 = makeDerivedDataFolder(name: "Folder1")
        let folder2 = makeDerivedDataFolder(name: "Folder2")
        let (sut, _, delegate, _, _) = makeSUT(throwError: true)

        #expect(throws: NSError.self) {
            try sut.deleteFolders([folder1, folder2], force: false, progressHandler: nil)
        }

        #expect(delegate.deletedFolders.isEmpty)
    }
}


// MARK: - Xcode Running Tests
extension DerivedDataManagerTests {
    @Test("Prevents deletion when Xcode is running")
    func preventsDeletionWhenXcodeIsRunning() throws {
        let folder = makeDerivedDataFolder(name: "TestFolder")
        let (sut, _, delegate, _, _) = makeSUT(isXcodeRunning: true)

        #expect(throws: DerivedDataError.xcodeIsRunning) {
            try sut.deleteFolders([folder], force: false, progressHandler: nil)
        }

        #expect(delegate.deletedFolders.isEmpty)
    }

    @Test("Allows deletion when Xcode is not running")
    func allowsDeletionWhenXcodeIsNotRunning() throws {
        let folder = makeDerivedDataFolder(name: "TestFolder")
        let (sut, _, delegate, _, _) = makeSUT(isXcodeRunning: false)

        try sut.deleteFolders([folder], force: false, progressHandler: nil)

        #expect(delegate.deletedFolders.count == 1)
        guard delegate.deletedFolders.count >= 1 else { return }
        #expect(delegate.deletedFolders[0].name == folder.name)
    }

    @Test("Checks Xcode status before attempting any deletions")
    func checksXcodeStatusBeforeAttemptingAnyDeletions() throws {
        let folder1 = makeDerivedDataFolder(name: "Folder1")
        let folder2 = makeDerivedDataFolder(name: "Folder2")
        let folder3 = makeDerivedDataFolder(name: "Folder3")
        let folders = [folder1, folder2, folder3]
        let (sut, _, delegate, _, _) = makeSUT(isXcodeRunning: true)

        #expect(throws: DerivedDataError.xcodeIsRunning) {
            try sut.deleteFolders(folders, force: false, progressHandler: nil)
        }

        #expect(delegate.deletedFolders.isEmpty)
    }

    @Test("Does not call progress handler when Xcode is running")
    func doesNotCallProgressHandlerWhenXcodeIsRunning() throws {
        let folder = makeDerivedDataFolder(name: "TestFolder")
        let progressHandler = MockPurgeProgressHandler()
        let (sut, _, _, _, _) = makeSUT(isXcodeRunning: true)

        #expect(throws: DerivedDataError.xcodeIsRunning) {
            try sut.deleteFolders([folder], force: false, progressHandler: progressHandler)
        }

        #expect(progressHandler.progressUpdates.isEmpty)
        #expect(!progressHandler.didComplete)
    }

    @Test("Bypasses Xcode check when force is true")
    func bypassesXcodeCheckWhenForceIsTrue() throws {
        let folder = makeDerivedDataFolder(name: "TestFolder")
        let (sut, _, delegate, _, _) = makeSUT(isXcodeRunning: true)

        try sut.deleteFolders([folder], force: true, progressHandler: nil)

        #expect(delegate.deletedFolders.count == 1)
        guard delegate.deletedFolders.count >= 1 else { return }
        #expect(delegate.deletedFolders[0].name == folder.name)
    }

    @Test("Deletes multiple folders when force is true despite Xcode running")
    func deletesMultipleFoldersWhenForceIsTrueDespiteXcodeRunning() throws {
        let folder1 = makeDerivedDataFolder(name: "Folder1")
        let folder2 = makeDerivedDataFolder(name: "Folder2")
        let folder3 = makeDerivedDataFolder(name: "Folder3")
        let folders = [folder1, folder2, folder3]
        let (sut, _, delegate, _, _) = makeSUT(isXcodeRunning: true)

        try sut.deleteFolders(folders, force: true, progressHandler: nil)

        #expect(delegate.deletedFolders.count == 3)
        #expect(delegate.deletedFolders.contains(where: { $0.name == folder1.name }))
        #expect(delegate.deletedFolders.contains(where: { $0.name == folder2.name }))
        #expect(delegate.deletedFolders.contains(where: { $0.name == folder3.name }))
    }
}


// MARK: - Close Xcode Tests
extension DerivedDataManagerTests {
    @Test("Closes Xcode successfully when termination succeeds")
    func closesXcodeSuccessfullyWhenTerminationSucceeds() throws {
        let (sut, _, _, _, terminator) = makeSUT(isXcodeRunning: false, xcodeTerminationSucceeds: true)

        try sut.closeXcodeAndVerify(timeout: 0.1)

        #expect(terminator.terminationSucceeds)
    }

    @Test("Throws error when Xcode termination fails")
    func throwsErrorWhenXcodeTerminationFails() throws {
        let (sut, _, _, _, _) = makeSUT(xcodeTerminationSucceeds: false)

        #expect(throws: DerivedDataError.xcodeFailedToClose) {
            try sut.closeXcodeAndVerify(timeout: 0.1)
        }
    }

    @Test("Throws error when Xcode still running after timeout")
    func throwsErrorWhenXcodeStillRunningAfterTimeout() throws {
        let (sut, _, _, _, _) = makeSUT(isXcodeRunning: true, xcodeTerminationSucceeds: true)

        #expect(throws: DerivedDataError.xcodeFailedToClose) {
            try sut.closeXcodeAndVerify(timeout: 0.1)
        }
    }
}


// MARK: - Path Configuration Tests
extension DerivedDataManagerTests {
    @Test("Uses specified path for folder operations")
    func usesSpecifiedPathForFolderOperations() throws {
        let customPath = "/custom/xcode/path"
        let folder = makePurgeFolder(name: "TestFolder")
        let (sut, loader, _, _, _) = makeSUT(path: customPath, foldersToLoad: [folder])

        let loadedFolders = try sut.loadFolders()

        #expect(loader.loadedPath == customPath)
        #expect(loadedFolders.count == 1)
    }

    @Test("Deletes folders from custom path location")
    func deletesFoldersFromCustomPathLocation() throws {
        let customPath = "/custom/path/DerivedData"
        let folder = makePurgeFolder(name: "CustomPathFolder")
        let (sut, _, delegate, _, _) = makeSUT(path: customPath, foldersToLoad: [folder])

        let loadedFolders = try sut.loadFolders()
        try sut.deleteFolders(loadedFolders, force: false, progressHandler: nil)

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
        let (sut, _, _, _, _) = makeSUT()

        try sut.deleteFolders(folders, force: false, progressHandler: progressHandler)

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
        let (sut, _, _, _, _) = makeSUT()

        try sut.deleteFolders(foldersToDelete, force: false, progressHandler: progressHandler)

        #expect(progressHandler.progressUpdates.count == 3)
        guard progressHandler.progressUpdates.count >= 3 else { return }
        #expect(progressHandler.progressUpdates[0].message.contains(folder1.name))
        #expect(progressHandler.progressUpdates[1].message.contains(folder2.name))
        #expect(progressHandler.progressUpdates[2].message.contains(folder3.name))
    }

    @Test("Does not call progress handler when no folders to delete")
    func doesNotCallProgressHandlerWhenNoFoldersToDelete() throws {
        let progressHandler = MockPurgeProgressHandler()
        let (sut, _, _, _, _) = makeSUT(foldersToLoad: [])

        try sut.deleteFolders([], force: false, progressHandler: progressHandler)

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
        let (sut, _, _, _, _) = makeSUT()

        try sut.deleteFolders(folders, force: false, progressHandler: progressHandler)

        #expect(progressHandler.progressUpdates.count == 4)
        guard progressHandler.progressUpdates.count == 4 else { return }
        for (index, folder) in folders.enumerated() {
            #expect(progressHandler.progressUpdates[index].message.contains(folder.name))
        }
    }

    @Test("Works correctly when progress handler is nil")
    func worksCorrectlyWhenProgressHandlerIsNil() throws {
        let folder = makeDerivedDataFolder(name: "TestFolder")
        let (sut, _, delegate, _, _) = makeSUT()

        try sut.deleteFolders([folder], force: false, progressHandler: nil as (any PurgeProgressHandler)?)

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
        let (sut, _, _, _, _) = makeSUT()

        try sut.deleteFolders(folders, force: false, progressHandler: progressHandler)

        #expect(progressHandler.didComplete)
        #expect(progressHandler.completedMessage != nil)
    }
}


// MARK: - SUT
private extension DerivedDataManagerTests {
    func makeSUT(
        path: String = "/default/path",
        throwError: Bool = false,
        foldersToLoad: [any PurgeFolder] = [],
        isXcodeRunning: Bool = false,
        xcodeTerminationSucceeds: Bool = true
    ) -> (sut: DerivedDataManager, loader: MockPurgeFolderLoader, delegate: MockDerivedDataDelegate, xcodeChecker: MockXcodeStatusChecker, xcodeTerminator: MockXcodeTerminator) {
        let loader = MockPurgeFolderLoader(throwError: throwError, foldersToLoad: foldersToLoad)
        let delegate = MockDerivedDataDelegate(throwError: throwError)
        let xcodeChecker = MockXcodeStatusChecker(xcodeRunningStatus: isXcodeRunning)
        let xcodeTerminator = MockXcodeTerminator(terminationSucceeds: xcodeTerminationSucceeds)
        let sut = DerivedDataManager(path: path, loader: loader, delegate: delegate, xcodeChecker: xcodeChecker, xcodeTerminator: xcodeTerminator)

        return (sut, loader, delegate, xcodeChecker, xcodeTerminator)
    }

    // TODO: - move to CodePurgeTesting
    func makePurgeFolder(name: String = "TestFolder") -> MockPurgeFolder {
        return .init(name: name)
    }
}


// MARK: - Mocks
private extension DerivedDataManagerTests {
    final class MockDerivedDataDelegate: DerivedDataDelegate, @unchecked Sendable {
        private let throwError: Bool
        private var deletedURLs: [URL] = []

        var deletedFolders: [DerivedDataFolder] {
            deletedURLs.map { url in
                DerivedDataFolder(
                    url: url,
                    name: url.lastPathComponent,
                    path: url.path,
                    creationDate: nil,
                    modificationDate: nil
                )
            }
        }

        init(throwError: Bool = false) {
            self.throwError = throwError
        }

        func deleteFolder(_ folder: DerivedDataFolder) throws {
            try deleteItem(at: folder.url)
        }

        func deleteItem(at url: URL) throws {
            if throwError {
                throw NSError(domain: "MockDerivedDataDelegate", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
            }
            deletedURLs.append(url)
        }
    }

    struct MockXcodeStatusChecker: XcodeStatusChecker {
        let xcodeRunningStatus: Bool

        func isXcodeRunning() -> Bool {
            return xcodeRunningStatus
        }
    }

    struct MockXcodeTerminator: XcodeTerminator {
        let terminationSucceeds: Bool

        func terminateXcode() -> Bool {
            return terminationSucceeds
        }
    }
}
