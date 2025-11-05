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

        #expect(delegate.deletedArchives.isEmpty)
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

        try sut.deleteArchives(archivesToDelete, progressHandler: nil)

        #expect(delegate.deletedArchives.count == 2)
        guard delegate.deletedArchives.count >= 2 else { return }
        #expect(delegate.deletedArchives[0].name == archive1.name)
        #expect(delegate.deletedArchives[1].name == archive2.name)
    }

    @Test("Deletes single archive successfully")
    func deletesSingleArchiveSuccessfully() throws {
        let archive = makeArchiveFolder(name: "SingleArchive.xcarchive")
        let (sut, delegate) = makeSUT()

        try sut.deleteArchives([archive], progressHandler: nil)

        #expect(delegate.deletedArchives.count == 1)
        guard delegate.deletedArchives.count >= 1 else { return }
        #expect(delegate.deletedArchives[0].name == archive.name)
    }

    @Test("Completes successfully when given empty archive list")
    func completesSuccessfullyWhenGivenEmptyArchiveList() throws {
        let (sut, delegate) = makeSUT()

        try sut.deleteArchives([], progressHandler: nil)

        #expect(delegate.deletedArchives.isEmpty)
    }

    @Test("Propagates deletion error from delegate")
    func propagatesDeletionErrorFromDelegate() throws {
        let archive = makeArchiveFolder(name: "ErrorArchive.xcarchive")
        let (sut, _) = makeSUT(throwError: true)

        #expect(throws: NSError.self) {
            try sut.deleteArchives([archive], progressHandler: nil)
        }
    }

    @Test("Stops deletion on first error and does not continue")
    func stopsDeletionOnFirstErrorAndDoesNotContinue() throws {
        let archive1 = makeArchiveFolder(name: "Archive1.xcarchive")
        let archive2 = makeArchiveFolder(name: "Archive2.xcarchive")
        let (sut, delegate) = makeSUT(throwError: true)

        #expect(throws: NSError.self) {
            try sut.deleteArchives([archive1, archive2], progressHandler: nil)
        }

        #expect(delegate.deletedArchives.isEmpty)
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

        try sut.deleteArchives(archivesToDelete, progressHandler: progressHandler)

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

        try sut.deleteArchives(archives, progressHandler: progressHandler)

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

        try sut.deleteArchives(archives, progressHandler: progressHandler)

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

        try sut.deleteArchives([archive1, archive2], progressHandler: progressHandler)

        #expect(progressHandler.didComplete)
        #expect(progressHandler.completedMessage != nil)
    }

    @Test("Does not update progress but still completes when no archives to delete")
    func doesNotUpdateProgressButStillCompletesWhenNoArchivesToDelete() throws {
        let progressHandler = MockPurgeProgressHandler()
        let (sut, _) = makeSUT()

        try sut.deleteArchives([], progressHandler: progressHandler)

        #expect(progressHandler.progressUpdates.isEmpty)
        #expect(progressHandler.didComplete)
    }

    @Test("Works correctly when progress handler is nil")
    func worksCorrectlyWhenProgressHandlerIsNil() throws {
        let archive = makeArchiveFolder(name: "TestArchive.xcarchive")
        let (sut, delegate) = makeSUT()

        try sut.deleteArchives([archive], progressHandler: nil)

        #expect(delegate.deletedArchives.count == 1)
        guard delegate.deletedArchives.count >= 1 else { return }
        #expect(delegate.deletedArchives[0].name == archive.name)
    }
}


// MARK: - SUT
private extension ArchiveManagerTests {
    func makeSUT(throwError: Bool = false, foldersToLoad: [any PurgeFolder] = [], plist: [String: Any]? = nil) -> (sut: ArchiveManager, delegate: MockArchiveDelegate) {
        let loader = MockPurgeFolderLoader(throwError: throwError, foldersToLoad: foldersToLoad)
        let delegate = MockArchiveDelegate(throwError: throwError, plist: plist)
        let sut = ArchiveManager(config: .defaultConfig, loader: loader, delegate: delegate)

        return (sut, delegate)
    }
}


// MARK: - Mocks
private extension ArchiveManagerTests {
    final class MockArchiveDelegate: ArchiveDelegate, @unchecked Sendable {
        private let throwError: Bool
        private let plist: [String: Any]?

        private(set) var deletedArchives: [ArchiveFolder] = []

        init(throwError: Bool = false, plist: [String: Any]?) {
            self.plist = plist
            self.throwError = throwError
        }

        func deleteArchive(_ archive: ArchiveFolder) throws {
            if throwError {
                throw NSError(domain: "MockArchiveDelegate", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
            }
            deletedArchives.append(archive)
        }
        
        func parseFolderPList(_ folder: any PurgeFolder) -> [String : Any]? {
            return plist
        }
    }
}
