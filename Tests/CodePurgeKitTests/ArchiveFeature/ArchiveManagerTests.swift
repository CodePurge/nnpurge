//
//  ArchiveManagerTests.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 11/4/25.
//

import Testing
import Foundation
import CodePurgeTesting
@testable import CodePurgeKit

struct ArchiveManagerTests {
    @Test("Starting values empty")
    func emptyStartingValues() {
        let (_, delegate) = makeSUT()

        #expect(delegate.deletedURLs.isEmpty)
    }
}


// MARK: - Load Archives Tests
extension ArchiveManagerTests {
    @Test("Returns empty array from load archives when no folders available")
    func returnsEmptyArrayFromLoadArchivesWhenNoFoldersAvailable() throws {
        let (sut, _) = makeSUT(foldersToLoad: [])

        let loadedArchives = try sut.loadArchives()

        #expect(loadedArchives.isEmpty)
    }

    @Test("Returns empty array from load archives due to unimplemented transformation")
    func returnsEmptyArrayFromLoadArchivesDueToUnimplementedTransformation() throws {
        let folders: [any PurgeFolder] = [
            MockPurgeFolder(name: "Archive1"),
            MockPurgeFolder(name: "Archive2")
        ]
        let (sut, _) = makeSUT(foldersToLoad: folders)

        let loadedArchives = try sut.loadArchives()

        #expect(loadedArchives.isEmpty)
    }

    @Test("Transforms folder with plist data into archive with correct name")
    func transformsFolderWithPlistDataIntoArchiveWithCorrectName() throws {
        let archiveName = "MyAppArchive"
        let plist = makePlist(name: archiveName)
        let folder = MockPurgeFolder(name: "ShouldNotUseThis.xcarchive")
        let (sut, _) = makeSUT(foldersToLoad: [folder], plist: plist)

        let loadedArchives = try sut.loadArchives()

        #expect(loadedArchives.count == 1)
        let archive = try #require(loadedArchives.first)
        #expect(archive.name == archiveName)
    }

    @Test("Transforms folder with plist data into archive with correct creation date")
    func transformsFolderWithPlistDataIntoArchiveWithCorrectCreationDate() throws {
        let creationDate = Date(timeIntervalSince1970: 1609459200)
        let plist = makePlist(creationDate: creationDate)
        let folder = MockPurgeFolder(name: "Archive.xcarchive")
        let (sut, _) = makeSUT(foldersToLoad: [folder], plist: plist)

        let loadedArchives = try sut.loadArchives()

        #expect(loadedArchives.count == 1)
        let archive = try #require(loadedArchives.first)
        #expect(archive.creationDate == creationDate)
    }

    @Test("Transforms folder with plist data into archive with correct version number")
    func transformsFolderWithPlistDataIntoArchiveWithCorrectVersionNumber() throws {
        let versionNumber = "1.2.3"
        let plist = makePlist(versionNumber: versionNumber)
        let folder = MockPurgeFolder(name: "Archive.xcarchive")
        let (sut, _) = makeSUT(foldersToLoad: [folder], plist: plist)

        let loadedArchives = try sut.loadArchives()

        #expect(loadedArchives.count == 1)
        let archive = try #require(loadedArchives.first)
        #expect(archive.versionNumber == versionNumber)
    }

    @Test("Transforms folder with plist data into archive with correct upload status")
    func transformsFolderWithPlistDataIntoArchiveWithCorrectUploadStatus() throws {
        let uploadStatus = "Uploaded to TestFlight"
        let plist = makePlist(uploadStatus: uploadStatus)
        let folder = MockPurgeFolder(name: "Archive.xcarchive")
        let (sut, _) = makeSUT(foldersToLoad: [folder], plist: plist)

        let loadedArchives = try sut.loadArchives()

        #expect(loadedArchives.count == 1)
        let archive = try #require(loadedArchives.first)
        #expect(archive.uploadStatus == uploadStatus)
    }

    @Test("Transforms folder into archive with correct url from folder")
    func transformsFolderIntoArchiveWithCorrectUrlFromFolder() throws {
        let folderUrl = URL(fileURLWithPath: "/path/to/archive/MyArchive.xcarchive")
        let plist = makePlist()
        let folder = MockPurgeFolder(name: "MyArchive.xcarchive", url: folderUrl, path: folderUrl.path)
        let (sut, _) = makeSUT(foldersToLoad: [folder], plist: plist)

        let loadedArchives = try sut.loadArchives()

        #expect(loadedArchives.count == 1)
        let archive = try #require(loadedArchives.first)
        #expect(archive.url == folderUrl)
    }

    @Test("Transforms folder into archive with correct path from folder")
    func transformsFolderIntoArchiveWithCorrectPathFromFolder() throws {
        let folderPath = "/custom/path/to/MyArchive.xcarchive"
        let plist = makePlist()
        let folder = MockPurgeFolder(name: "MyArchive.xcarchive", url: URL(fileURLWithPath: folderPath), path: folderPath)
        let (sut, _) = makeSUT(foldersToLoad: [folder], plist: plist)

        let loadedArchives = try sut.loadArchives()

        #expect(loadedArchives.count == 1)
        let archive = try #require(loadedArchives.first)
        #expect(archive.path == folderPath)
    }

    @Test("Transforms folder into archive with correct modification date from folder")
    func transformsFolderIntoArchiveWithCorrectModificationDateFromFolder() throws {
        let modificationDate = Date(timeIntervalSince1970: 1612137600)
        let plist = makePlist()
        let folder = MockPurgeFolder(name: "Archive.xcarchive", modificationDate: modificationDate)
        let (sut, _) = makeSUT(foldersToLoad: [folder], plist: plist)

        let loadedArchives = try sut.loadArchives()

        #expect(loadedArchives.count == 1)
        let archive = try #require(loadedArchives.first)
        #expect(archive.modificationDate == modificationDate)
    }

    @Test("Transforms multiple folders with complete plist data into archives")
    func transformsMultipleFoldersWithCompletePlistDataIntoArchives() throws {
        let name1 = "FirstArchive"
        let name2 = "SecondArchive"
        let version1 = "1.0.0"
        let version2 = "2.0.0"
        let date1 = Date(timeIntervalSince1970: 1609459200)
        let date2 = Date(timeIntervalSince1970: 1612137600)
        let plist1 = makePlist(name: name1, versionNumber: version1, creationDate: date1)
        let plist2 = makePlist(name: name2, versionNumber: version2, creationDate: date2)
        let folder1 = MockPurgeFolder(name: "Archive1.xcarchive", path: "/path/to/folder1")
        let folder2 = MockPurgeFolder(name: "Archive2.xcarchive", path: "/path/to/folder2")
        let (sut, delegate) = makeSUT(foldersToLoad: [folder1, folder2])
        delegate.plistByFolder = [folder1.path: plist1, folder2.path: plist2]

        let loadedArchives = try sut.loadArchives()

        #expect(loadedArchives.count == 2)
        let firstArchive = loadedArchives.first { $0.name == name1 }
        let secondArchive = loadedArchives.first { $0.name == name2 }
        #expect(firstArchive != nil)
        #expect(secondArchive != nil)
        #expect(firstArchive?.versionNumber == version1)
        #expect(secondArchive?.versionNumber == version2)
        #expect(firstArchive?.creationDate == date1)
        #expect(secondArchive?.creationDate == date2)
    }

    @Test("Propagates load folders error from loader")
    func propagatesLoadFoldersErrorFromLoader() throws {
        let (sut, _) = makeSUT(throwError: true)

        #expect(throws: NSError.self) {
            try sut.loadArchives()
        }
    }
}


// MARK: - Delete Archives Tests
extension ArchiveManagerTests {
    @Test("Deletes specified archives in correct order")
    func deletesSpecifiedArchivesInCorrectOrder() throws {
        let archive1 = makeArchiveFolder(name: "Archive1.xcarchive")
        let archive2 = makeArchiveFolder(name: "Archive2.xcarchive")
        let archivesToDelete = [archive1, archive2]
        let (sut, delegate) = makeSUT()

        try sut.deleteArchives(archivesToDelete, force: false, progressHandler: nil)

        #expect(delegate.deletedURLs.count == 2)
        guard delegate.deletedURLs.count >= 2 else { return }
        #expect(delegate.deletedURLs[0] == archive1.url)
        #expect(delegate.deletedURLs[1] == archive2.url)
    }

    @Test("Deletes single archive successfully")
    func deletesSingleArchiveSuccessfully() throws {
        let archive = makeArchiveFolder(name: "SingleArchive.xcarchive")
        let (sut, delegate) = makeSUT()

        try sut.deleteArchives([archive], force: false, progressHandler: nil)

        #expect(delegate.deletedURLs.count == 1)
        guard delegate.deletedURLs.count >= 1 else { return }
        #expect(delegate.deletedURLs[0] == archive.url)
    }

    @Test("Throws error when given empty archive list")
    func throwsErrorWhenGivenEmptyArchiveList() throws {
        let (sut, delegate) = makeSUT()

        #expect(throws: PurgableItemError.noItemsToDelete) {
            try sut.deleteArchives([], force: false, progressHandler: nil)
        }

        #expect(delegate.deletedURLs.isEmpty)
    }

    @Test("Propagates deletion error from delegate")
    func propagatesDeletionErrorFromDelegate() throws {
        let archive = makeArchiveFolder(name: "ErrorArchive.xcarchive")
        let (sut, _) = makeSUT(throwError: true)

        #expect(throws: NSError.self) {
            try sut.deleteArchives([archive], force: false, progressHandler: nil)
        }
    }

    @Test("Stops deletion on first error and does not continue")
    func stopsDeletionOnFirstErrorAndDoesNotContinue() throws {
        let archive1 = makeArchiveFolder(name: "Archive1.xcarchive")
        let archive2 = makeArchiveFolder(name: "Archive2.xcarchive")
        let (sut, delegate) = makeSUT(throwError: true)

        #expect(throws: NSError.self) {
            try sut.deleteArchives([archive1, archive2], force: false, progressHandler: nil)
        }

        #expect(delegate.deletedURLs.isEmpty)
    }
}


// MARK: - Empty Archives Check Tests
extension ArchiveManagerTests {
    @Test("Throws noItemsToDelete error before checking Xcode status")
    func throwsNoItemsToDeleteErrorBeforeCheckingXcodeStatus() throws {
        let (sut, _) = makeSUT(isXcodeRunning: true)
        let emptyArchives: [ArchiveFolder] = []

        #expect(throws: PurgableItemError.noItemsToDelete) {
            try sut.deleteArchives(emptyArchives, force: false, progressHandler: nil)
        }
    }

    @Test("Throws noItemsToDelete error even when force is true")
    func throwsNoItemsToDeleteErrorEvenWhenForceIsTrue() throws {
        let (sut, delegate) = makeSUT()
        let emptyArchives: [ArchiveFolder] = []

        #expect(throws: PurgableItemError.noItemsToDelete) {
            try sut.deleteArchives(emptyArchives, force: true, progressHandler: nil)
        }

        #expect(delegate.deletedURLs.isEmpty)
    }

    @Test("Does not call delegate when archives array is empty")
    func doesNotCallDelegateWhenArchivesArrayIsEmpty() throws {
        let (sut, delegate) = makeSUT()
        let emptyArchives: [ArchiveFolder] = []

        #expect(throws: PurgableItemError.noItemsToDelete) {
            try sut.deleteArchives(emptyArchives, force: false, progressHandler: nil)
        }

        #expect(delegate.deletedURLs.isEmpty)
    }
}


// MARK: - Progress Handler Tests
extension ArchiveManagerTests {
    @Test("Calls progress handler for each archive during deletion")
    func callsProgressHandlerForEachArchiveDuringDeletion() throws {
        let archive1 = makeArchiveFolder(name: "Alpha.xcarchive")
        let archive2 = makeArchiveFolder(name: "Beta.xcarchive")
        let archive3 = makeArchiveFolder(name: "Gamma.xcarchive")
        let archivesToDelete = [archive1, archive2, archive3]
        let progressHandler = MockPurgeProgressHandler()
        let (sut, _) = makeSUT()

        try sut.deleteArchives(archivesToDelete, force: false, progressHandler: progressHandler)

        #expect(progressHandler.progressUpdates.count == 3)
        guard progressHandler.progressUpdates.count >= 3 else { return }
        #expect(progressHandler.progressUpdates[0].message.contains(archive1.name))
        #expect(progressHandler.progressUpdates[1].message.contains(archive2.name))
        #expect(progressHandler.progressUpdates[2].message.contains(archive3.name))
    }

    @Test("Calls progress handler in correct deletion order")
    func callsProgressHandlerInCorrectDeletionOrder() throws {
        let archive1 = makeArchiveFolder(name: "First.xcarchive")
        let archive2 = makeArchiveFolder(name: "Second.xcarchive")
        let archive3 = makeArchiveFolder(name: "Third.xcarchive")
        let archive4 = makeArchiveFolder(name: "Fourth.xcarchive")
        let archives = [archive1, archive2, archive3, archive4]
        let progressHandler = MockPurgeProgressHandler()
        let (sut, _) = makeSUT()

        try sut.deleteArchives(archives, force: false, progressHandler: progressHandler)

        #expect(progressHandler.progressUpdates.count == 4)
        guard progressHandler.progressUpdates.count == 4 else { return }
        for (index, archive) in archives.enumerated() {
            #expect(progressHandler.progressUpdates[index].message.contains(archive.name))
        }
    }

    @Test("Updates progress with correct current and total counts")
    func updatesProgressWithCorrectCurrentAndTotalCounts() throws {
        let archive1 = makeArchiveFolder(name: "One.xcarchive")
        let archive2 = makeArchiveFolder(name: "Two.xcarchive")
        let archive3 = makeArchiveFolder(name: "Three.xcarchive")
        let archives = [archive1, archive2, archive3]
        let progressHandler = MockPurgeProgressHandler()
        let (sut, _) = makeSUT()

        try sut.deleteArchives(archives, force: false, progressHandler: progressHandler)

        #expect(progressHandler.progressUpdates.count == 3)
        guard progressHandler.progressUpdates.count >= 3 else { return }
        #expect(progressHandler.progressUpdates[0].index == 1)
        #expect(progressHandler.progressUpdates[1].index == 2)
        #expect(progressHandler.progressUpdates[2].index == 3)
    }

    @Test("Calls complete on progress handler after all deletions")
    func callsCompleteOnProgressHandlerAfterAllDeletions() throws {
        let archive1 = makeArchiveFolder(name: "Archive1.xcarchive")
        let archive2 = makeArchiveFolder(name: "Archive2.xcarchive")
        let progressHandler = MockPurgeProgressHandler()
        let (sut, _) = makeSUT()

        try sut.deleteArchives([archive1, archive2], force: false, progressHandler: progressHandler)

        #expect(progressHandler.didComplete)
        #expect(progressHandler.completedMessage != nil)
    }

    @Test("Throws error and does not call progress handler when no archives to delete")
    func throwsErrorAndDoesNotCallProgressHandlerWhenNoArchivesToDelete() throws {
        let progressHandler = MockPurgeProgressHandler()
        let (sut, _) = makeSUT()

        #expect(throws: PurgableItemError.noItemsToDelete) {
            try sut.deleteArchives([], force: false, progressHandler: progressHandler)
        }

        #expect(progressHandler.progressUpdates.isEmpty)
        #expect(!progressHandler.didComplete)
    }

    @Test("Works correctly when progress handler is nil")
    func worksCorrectlyWhenProgressHandlerIsNil() throws {
        let archive = makeArchiveFolder(name: "TestArchive.xcarchive")
        let (sut, delegate) = makeSUT()

        try sut.deleteArchives([archive], force: false, progressHandler: nil)

        #expect(delegate.deletedURLs.count == 1)
        guard delegate.deletedURLs.count >= 1 else { return }
        #expect(delegate.deletedURLs[0] == archive.url)
    }
}


// MARK: - Xcode Safety Tests
extension ArchiveManagerTests {
    @Test("Throws xcodeIsRunning error when Xcode is running and force is false")
    func throwsXcodeIsRunningErrorWhenXcodeIsRunningAndForceIsFalse() throws {
        let archive = makeArchiveFolder(name: "TestArchive.xcarchive")
        let (sut, _) = makeSUT(isXcodeRunning: true)

        #expect(throws: ArchiveError.xcodeIsRunning) {
            try sut.deleteArchives([archive], force: false, progressHandler: nil)
        }
    }

    @Test("Proceeds with deletion when force is true even if Xcode is running")
    func proceedsWithDeletionWhenForceIsTrueEvenIfXcodeIsRunning() throws {
        let archive = makeArchiveFolder(name: "TestArchive.xcarchive")
        let (sut, delegate) = makeSUT(isXcodeRunning: true)

        try sut.deleteArchives([archive], force: true, progressHandler: nil)

        #expect(delegate.deletedURLs.count == 1)
        #expect(delegate.deletedURLs.first == archive.url)
    }

    @Test("Does not throw when Xcode is not running")
    func doesNotThrowWhenXcodeIsNotRunning() throws {
        let archive = makeArchiveFolder(name: "TestArchive.xcarchive")
        let (sut, delegate) = makeSUT(isXcodeRunning: false)

        try sut.deleteArchives([archive], force: false, progressHandler: nil)

        #expect(delegate.deletedURLs.count == 1)
    }

    @Test("Successfully closes Xcode and verifies")
    func successfullyClosesXcodeAndVerifies() throws {
        let (sut, _) = makeSUT(isXcodeRunning: false, terminationSucceeds: true)

        try sut.closeXcodeAndVerify(timeout: 1.0)
    }

    @Test("Throws error when Xcode termination fails")
    func throwsErrorWhenXcodeTerminationFails() throws {
        let (sut, _) = makeSUT(terminationSucceeds: false)

        #expect(throws: ArchiveError.xcodeFailedToClose) {
            try sut.closeXcodeAndVerify(timeout: 1.0)
        }
    }

    @Test("Throws error when Xcode still running after timeout")
    func throwsErrorWhenXcodeStillRunningAfterTimeout() throws {
        let (sut, _) = makeSUT(isXcodeRunning: true, terminationSucceeds: true)

        #expect(throws: ArchiveError.xcodeFailedToClose) {
            try sut.closeXcodeAndVerify(timeout: 0.1)
        }
    }
}


// MARK: - SUT
private extension ArchiveManagerTests {
    func makeSUT(
        throwError: Bool = false,
        foldersToLoad: [any PurgeFolder] = [],
        plist: [String: Any]? = nil,
        isXcodeRunning: Bool = false,
        terminationSucceeds: Bool = true
    ) -> (sut: ArchiveManager, delegate: MockArchiveDelegate) {
        let loader = MockPurgeFolderLoader(throwError: throwError, foldersToLoad: foldersToLoad)
        let delegate = MockArchiveDelegate(throwError: throwError, plist: plist)
        let xcodeChecker = MockXcodeStatusChecker(xcodeRunningStatus: isXcodeRunning)
        let xcodeTerminator = MockXcodeTerminator(terminationSucceeds: terminationSucceeds)
        let sut = ArchiveManager(config: .defaultConfig, loader: loader, delegate: delegate, xcodeChecker: xcodeChecker, xcodeTerminator: xcodeTerminator)

        return (sut, delegate)
    }

    func makeArchiveFolder(name: String) -> ArchiveFolder {
        let url = URL(fileURLWithPath: "/path/to/Archives/\(name)")

        return .init(
            url: url,
            name: name,
            path: url.path,
            creationDate: Date(),
            modificationDate: Date(),
            size: nil,
            imageData: nil,
            uploadStatus: nil,
            versionNumber: nil
        )
    }

    func makePlist(name: String = "TestArchive", versionNumber: String = "1.0.0", creationDate: Date? = nil, uploadStatus: String? = nil) -> [String: Any] {
        var plist: [String: Any] = [
            "Name": name,
            "ApplicationProperties": [
                "CFBundleShortVersionString": versionNumber
            ]
        ]

        if let creationDate {
            plist["CreationDate"] = creationDate
        }

        if let uploadStatus {
            plist["Distributions"] = [
                [
                    "uploadEvent": [
                        "shortTitle": uploadStatus
                    ]
                ]
            ]
        }

        return plist
    }
}


// MARK: - Mocks
private extension ArchiveManagerTests {
    final class MockArchiveDelegate: ArchiveDelegate, @unchecked Sendable {
        private let throwError: Bool
        private let plist: [String: Any]?

        private(set) var deletedURLs: [URL] = []
        var plistByFolder: [String: [String: Any]] = [:]

        init(throwError: Bool = false, plist: [String: Any]?) {
            self.plist = plist
            self.throwError = throwError
        }

        func deleteArchive(_ archive: ArchiveFolder) throws {
            try deleteItem(at: archive.url)
        }

        func deleteItem(at url: URL) throws {
            if throwError {
                throw NSError(domain: "MockArchiveDelegate", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
            }
            deletedURLs.append(url)
        }

        func parseFolderPList(_ folder: any PurgeFolder) -> [String : Any]? {
            if !plistByFolder.isEmpty {
                return plistByFolder[folder.path]
            }
            return plist
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
