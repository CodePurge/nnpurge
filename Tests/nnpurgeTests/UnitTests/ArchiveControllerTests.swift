//
//  ArchiveControllerTests.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/4/25.
//

import Testing
import Foundation
import SwiftPicker
import CodePurgeKit
import CodePurgeTesting
import SwiftPickerTesting
@testable import nnpurge

struct ArchiveControllerTests {
    @Test("Starting values empty")
    func emptyStartingValues() {
        let (_, service, progressHandler) = makeSUT()

        #expect(!service.didDeleteArchives)
        #expect(service.deletedArchives.isEmpty)
        #expect(!progressHandler.didComplete)
        #expect(progressHandler.completedMessage == nil)
        #expect(progressHandler.progressUpdates.isEmpty)
    }
}


// MARK: - Delete All Flag Tests
extension ArchiveControllerTests {
    @Test("Deletes all archives when flag true and permission granted")
    func deletesAllArchivesWhenFlagTrueAndPermissionGranted() throws {
        let (sut, service, _) = makeSUT(
            permissionResult: .init(type: .ordered([true]))
        )

        try sut.deleteArchives(deleteAll: true)

        #expect(service.didDeleteArchives)
    }

    @Test("Throws error when delete all flag true but permission denied")
    func throwsErrorWhenDeleteAllFlagTrueButPermissionDenied() throws {
        let (sut, _, _) = makeSUT(
            permissionResult: .init(type: .ordered([false]))
        )

        #expect(throws: SwiftPickerError.selectionCancelled) {
            try sut.deleteArchives(deleteAll: true)
        }
    }

    @Test("Requests permission with correct prompt when deleting all")
    func requestsPermissionWithCorrectPromptWhenDeletingAll() throws {
        let expectedPrompt = "Are you sure you want to delete all Xcode archives?"
        let (sut, _, _) = makeSUT(
            permissionResult: .init(
                type: .dictionary([expectedPrompt: true])
            )
        )

        try sut.deleteArchives(deleteAll: true)
    }
}


// MARK: - Select Option Flow Tests
extension ArchiveControllerTests {
    @Test("Shows option selection when delete all flag false")
    func showsOptionSelectionWhenDeleteAllFlagFalse() throws {
        let (sut, _, _) = makeSUT(
            permissionResult: .init(type: .ordered([true])),
            selectionResult: .init(
                singleSelectionType: .ordered([0])
            )
        )

        try sut.deleteArchives(deleteAll: false)
    }

    @Test("Throws error when user cancels option selection")
    func throwsErrorWhenUserCancelsOptionSelection() throws {
        let (sut, _, _) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([nil])
            )
        )

        #expect(throws: SwiftPickerError.selectionCancelled) {
            try sut.deleteArchives(deleteAll: false)
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

        try sut.deleteArchives(deleteAll: false)

        #expect(service.didDeleteArchives)
    }

    @Test("Shows archive selection when user selects select folders option")
    func showsArchiveSelectionWhenUserSelectsSelectFoldersOption() throws {
        let selectFoldersIndex = 2
        let archives = [
            makeArchiveFolder(name: "Archive1.xcarchive"),
            makeArchiveFolder(name: "Archive2.xcarchive")
        ]
        let (sut, service, _) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([selectFoldersIndex]),
                multiSelectionType: .ordered([[0]])
            ),
            archivesToLoad: archives
        )

        try sut.deleteArchives(deleteAll: false)

        #expect(service.deletedArchives.count == 1)
        #expect(service.deletedArchives.first?.name == archives[0].name)
    }
}


// MARK: - Delete Stale Archives Flow Tests
extension ArchiveControllerTests {
    @Test("Deletes stale archives when user selects delete stale option")
    func deletesStaleArchivesWhenUserSelectsDeleteStaleOption() throws {
        let staleDate = Calendar.current.date(byAdding: .day, value: -35, to: Date())
        let staleArchive1 = makeArchiveFolder(name: "Stale1.xcarchive", modificationDate: staleDate)
        let staleArchive2 = makeArchiveFolder(name: "Stale2.xcarchive", modificationDate: staleDate)
        let recentArchive = makeArchiveFolder(name: "Recent.xcarchive", modificationDate: Date())
        let archives = [staleArchive1, staleArchive2, recentArchive]
        let deleteStaleIndex = 1
        let (sut, service, _) = makeSUT(
            permissionResult: .init(type: .ordered([true])),
            selectionResult: .init(
                singleSelectionType: .ordered([deleteStaleIndex])
            ),
            archivesToLoad: archives
        )

        try sut.deleteArchives(deleteAll: false)

        #expect(service.deletedArchives.count == 2)
        #expect(service.deletedArchives.contains(where: { $0.name == staleArchive1.name }))
        #expect(service.deletedArchives.contains(where: { $0.name == staleArchive2.name }))
    }

    @Test("Deletes no archives when no stale archives found")
    func deletesNoArchivesWhenNoStaleArchivesFound() throws {
        let recentArchive1 = makeArchiveFolder(name: "Recent1.xcarchive", modificationDate: Date())
        let recentArchive2 = makeArchiveFolder(name: "Recent2.xcarchive", modificationDate: Date())
        let archives = [recentArchive1, recentArchive2]
        let deleteStaleIndex = 1
        let (sut, service, _) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([deleteStaleIndex])
            ),
            archivesToLoad: archives
        )

        try sut.deleteArchives(deleteAll: false)

        #expect(service.deletedArchives.isEmpty)
    }

    @Test("Requests permission with correct count when deleting stale archives")
    func requestsPermissionWithCorrectCountWhenDeletingStaleArchives() throws {
        let staleDate = Calendar.current.date(byAdding: .day, value: -35, to: Date())
        let staleArchive1 = makeArchiveFolder(name: "Stale1.xcarchive", modificationDate: staleDate)
        let staleArchive2 = makeArchiveFolder(name: "Stale2.xcarchive", modificationDate: staleDate)
        let staleArchive3 = makeArchiveFolder(name: "Stale3.xcarchive", modificationDate: staleDate)
        let archives = [staleArchive1, staleArchive2, staleArchive3]
        let deleteStaleIndex = 1
        let expectedPrompt = "Found 3 stale archive(s). Delete them?"
        let (sut, _, _) = makeSUT(
            permissionResult: .init(
                type: .dictionary([expectedPrompt: true])
            ),
            selectionResult: .init(
                singleSelectionType: .ordered([deleteStaleIndex])
            ),
            archivesToLoad: archives
        )

        try sut.deleteArchives(deleteAll: false)
    }

    @Test("Throws error when user denies permission for stale deletion")
    func throwsErrorWhenUserDeniesPermissionForStaleDeletion() throws {
        let staleDate = Calendar.current.date(byAdding: .day, value: -35, to: Date())
        let staleArchive = makeArchiveFolder(name: "Stale.xcarchive", modificationDate: staleDate)
        let archives = [staleArchive]
        let deleteStaleIndex = 1
        let (sut, _, _) = makeSUT(
            permissionResult: .init(type: .ordered([false])),
            selectionResult: .init(
                singleSelectionType: .ordered([deleteStaleIndex])
            ),
            archivesToLoad: archives
        )

        #expect(throws: SwiftPickerError.selectionCancelled) {
            try sut.deleteArchives(deleteAll: false)
        }
    }

    @Test("Filters archives using modification date when both dates exist")
    func filtersArchivesUsingModificationDateWhenBothDatesExist() throws {
        let staleModificationDate = Calendar.current.date(byAdding: .day, value: -35, to: Date())
        let recentCreationDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())
        let archive = makeArchiveFolder(
            name: "Archive.xcarchive",
            creationDate: recentCreationDate,
            modificationDate: staleModificationDate
        )
        let archives = [archive]
        let deleteStaleIndex = 1
        let (sut, service, _) = makeSUT(
            permissionResult: .init(type: .ordered([true])),
            selectionResult: .init(
                singleSelectionType: .ordered([deleteStaleIndex])
            ),
            archivesToLoad: archives
        )

        try sut.deleteArchives(deleteAll: false)

        #expect(service.deletedArchives.count == 1)
        #expect(service.deletedArchives.first?.name == archive.name)
    }

    @Test("Filters archives using creation date when modification date nil")
    func filtersArchivesUsingCreationDateWhenModificationDateNil() throws {
        let staleCreationDate = Calendar.current.date(byAdding: .day, value: -35, to: Date())
        let archive = makeArchiveFolder(
            name: "Archive.xcarchive",
            creationDate: staleCreationDate,
            modificationDate: nil
        )
        let archives = [archive]
        let deleteStaleIndex = 1
        let (sut, service, _) = makeSUT(
            permissionResult: .init(type: .ordered([true])),
            selectionResult: .init(
                singleSelectionType: .ordered([deleteStaleIndex])
            ),
            archivesToLoad: archives
        )

        try sut.deleteArchives(deleteAll: false)

        #expect(service.deletedArchives.count == 1)
        #expect(service.deletedArchives.first?.name == archive.name)
    }

    @Test("Excludes archives with no dates from stale deletion")
    func excludesArchivesWithNoDatesFromStaleDeletion() throws {
        let archive = makeArchiveFolder(
            name: "Archive.xcarchive",
            creationDate: nil,
            modificationDate: nil
        )
        let archives = [archive]
        let deleteStaleIndex = 1
        let (sut, service, _) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([deleteStaleIndex])
            ),
            archivesToLoad: archives
        )

        try sut.deleteArchives(deleteAll: false)

        #expect(service.deletedArchives.isEmpty)
    }

    @Test("Excludes archives newer than thirty days from stale deletion")
    func excludesArchivesNewerThanThirtyDaysFromStaleDeletion() throws {
        let recentDate = Calendar.current.date(byAdding: .day, value: -15, to: Date())
        let archive = makeArchiveFolder(name: "Recent.xcarchive", modificationDate: recentDate)
        let archives = [archive]
        let deleteStaleIndex = 1
        let (sut, service, _) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([deleteStaleIndex])
            ),
            archivesToLoad: archives
        )

        try sut.deleteArchives(deleteAll: false)

        #expect(service.deletedArchives.isEmpty)
    }

    @Test("Includes archives exactly thirty days old in stale deletion")
    func includesArchivesExactlyThirtyDaysOldInStaleDeletion() throws {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())
        let archive = makeArchiveFolder(name: "Exact.xcarchive", modificationDate: thirtyDaysAgo)
        let archives = [archive]
        let deleteStaleIndex = 1
        let (sut, service, _) = makeSUT(
            permissionResult: .init(type: .ordered([true])),
            selectionResult: .init(
                singleSelectionType: .ordered([deleteStaleIndex])
            ),
            archivesToLoad: archives
        )

        try sut.deleteArchives(deleteAll: false)

        #expect(service.deletedArchives.count == 1)
        #expect(service.deletedArchives.first?.name == archive.name)
    }
}


// MARK: - Select Archives Flow Tests
extension ArchiveControllerTests {
    @Test("Deletes selected archives when user makes selection")
    func deletesSelectedArchivesWhenUserMakesSelection() throws {
        let archive1 = makeArchiveFolder(name: "Archive1.xcarchive")
        let archive2 = makeArchiveFolder(name: "Archive2.xcarchive")
        let archive3 = makeArchiveFolder(name: "Archive3.xcarchive")
        let archives = [archive1, archive2, archive3]
        let selectedIndices = [0, 2]
        let (sut, service, _) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([2]),
                multiSelectionType: .ordered([selectedIndices])
            ),
            archivesToLoad: archives
        )

        try sut.deleteArchives(deleteAll: false)

        #expect(service.deletedArchives.count == 2)
        #expect(service.deletedArchives.contains(where: { $0.name == archive1.name }))
        #expect(service.deletedArchives.contains(where: { $0.name == archive3.name }))
    }

    @Test("Deletes no archives when user selects none")
    func deletesNoArchivesWhenUserSelectsNone() throws {
        let archives = [
            makeArchiveFolder(name: "Archive1.xcarchive"),
            makeArchiveFolder(name: "Archive2.xcarchive")
        ]
        let (sut, service, _) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([2]),
                multiSelectionType: .ordered([[]])
            ),
            archivesToLoad: archives
        )

        try sut.deleteArchives(deleteAll: false)

        #expect(service.deletedArchives.isEmpty)
    }

    @Test("Shows multi selection with correct prompt and archives")
    func showsMultiSelectionWithCorrectPromptAndArchives() throws {
        let expectedPrompt = "Select the archives to delete."
        let archives = [
            makeArchiveFolder(name: "Archive1.xcarchive"),
            makeArchiveFolder(name: "Archive2.xcarchive")
        ]
        let (sut, _, _) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([2]),
                multiSelectionType: .dictionary([expectedPrompt: [0]])
            ),
            archivesToLoad: archives
        )

        try sut.deleteArchives(deleteAll: false)
    }
}


// MARK: - Error Handling Tests
extension ArchiveControllerTests {
    @Test("Propagates delete all error from service")
    func propagatesDeleteAllErrorFromService() throws {
        let (sut, _, _) = makeSUT(
            permissionResult: .init(type: .ordered([true])),
            throwError: true
        )

        #expect(throws: NSError.self) {
            try sut.deleteArchives(deleteAll: true)
        }
    }

    @Test("Propagates delete archives error from service")
    func propagatesDeleteArchivesErrorFromService() throws {
        let archives = [makeArchiveFolder(name: "Archive1.xcarchive")]
        let (sut, _, _) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([2]),
                multiSelectionType: .ordered([[0]])
            ),
            throwError: true,
            archivesToLoad: archives
        )

        #expect(throws: NSError.self) {
            try sut.deleteArchives(deleteAll: false)
        }
    }

    @Test("Propagates load archives error from service")
    func propagatesLoadArchivesErrorFromService() throws {
        let (sut, _, _) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([0])
            ),
            throwError: true
        )

        #expect(throws: NSError.self) {
            try sut.deleteArchives(deleteAll: false)
        }
    }
}


// MARK: - Progress Handler Tests
extension ArchiveControllerTests {
    @Test("Reports progress for each archive when deleting all")
    func reportsProgressForEachArchiveWhenDeletingAll() throws {
        let archive1 = makeArchiveFolder(name: "Archive1.xcarchive")
        let archive2 = makeArchiveFolder(name: "Archive2.xcarchive")
        let archive3 = makeArchiveFolder(name: "Archive3.xcarchive")
        let archives = [archive1, archive2, archive3]
        let (sut, _, progressHandler) = makeSUT(
            permissionResult: .init(type: .ordered([true])),
            archivesToLoad: archives
        )

        try sut.deleteArchives(deleteAll: true)

        #expect(progressHandler.progressUpdates.count == archives.count)
        guard progressHandler.progressUpdates.count >= 3 else { return }
        #expect(progressHandler.progressUpdates[0].message.contains(archive1.name))
        #expect(progressHandler.progressUpdates[1].message.contains(archive2.name))
        #expect(progressHandler.progressUpdates[2].message.contains(archive3.name))
    }

    @Test("Reports progress for each selected archive when deleting specific archives")
    func reportsProgressForEachSelectedArchiveWhenDeletingSpecificArchives() throws {
        let archive1 = makeArchiveFolder(name: "Archive1.xcarchive")
        let archive2 = makeArchiveFolder(name: "Archive2.xcarchive")
        let archive3 = makeArchiveFolder(name: "Archive3.xcarchive")
        let archives = [archive1, archive2, archive3]
        let selectedIndices = [0, 2]
        let (sut, _, progressHandler) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([2]),
                multiSelectionType: .ordered([selectedIndices])
            ),
            archivesToLoad: archives
        )

        try sut.deleteArchives(deleteAll: false)

        #expect(progressHandler.progressUpdates.count == 2)
        guard progressHandler.progressUpdates.count >= 2 else { return }
        #expect(progressHandler.progressUpdates[0].message.contains(archive1.name))
        #expect(progressHandler.progressUpdates[1].message.contains(archive3.name))
    }

    @Test("Reports no progress when no archives selected")
    func reportsNoProgressWhenNoArchivesSelected() throws {
        let archives = [
            makeArchiveFolder(name: "Archive1.xcarchive"),
            makeArchiveFolder(name: "Archive2.xcarchive")
        ]
        let (sut, _, progressHandler) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([2]),
                multiSelectionType: .ordered([[]])
            ),
            archivesToLoad: archives
        )

        try sut.deleteArchives(deleteAll: false)

        #expect(progressHandler.progressUpdates.isEmpty)
    }

    @Test("Reports progress in correct order for multiple archives")
    func reportsProgressInCorrectOrderForMultipleArchives() throws {
        let archive1 = makeArchiveFolder(name: "Alpha.xcarchive")
        let archive2 = makeArchiveFolder(name: "Beta.xcarchive")
        let archive3 = makeArchiveFolder(name: "Gamma.xcarchive")
        let archive4 = makeArchiveFolder(name: "Delta.xcarchive")
        let archives = [archive1, archive2, archive3, archive4]
        let (sut, _, progressHandler) = makeSUT(
            permissionResult: .init(type: .ordered([true])),
            archivesToLoad: archives
        )

        try sut.deleteArchives(deleteAll: true)

        #expect(progressHandler.progressUpdates.count == 4)
        for (index, archive) in archives.enumerated() {
            #expect(progressHandler.progressUpdates[index].message.contains(archive.name))
        }
    }
}


// MARK: - Load Archives Tests
extension ArchiveControllerTests {
    @Test("Loads all archives when deleting all")
    func loadsAllArchivesWhenDeletingAll() throws {
        let archive1 = makeArchiveFolder(name: "Archive1.xcarchive")
        let archive2 = makeArchiveFolder(name: "Archive2.xcarchive")
        let archives = [archive1, archive2]
        let (sut, service, _) = makeSUT(
            permissionResult: .init(type: .ordered([true])),
            archivesToLoad: archives
        )

        try sut.deleteArchives(deleteAll: true)

        #expect(service.deletedArchives.count == archives.count)
    }

    @Test("Loads all archives when selecting specific archives")
    func loadsAllArchivesWhenSelectingSpecificArchives() throws {
        let archive1 = makeArchiveFolder(name: "Archive1.xcarchive")
        let archive2 = makeArchiveFolder(name: "Archive2.xcarchive")
        let archive3 = makeArchiveFolder(name: "Archive3.xcarchive")
        let archives = [archive1, archive2, archive3]
        let (sut, service, _) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([2]),
                multiSelectionType: .ordered([[1]])
            ),
            archivesToLoad: archives
        )

        try sut.deleteArchives(deleteAll: false)

        #expect(service.deletedArchives.count == 1)
        #expect(service.deletedArchives.first?.name == archive2.name)
    }
}


// MARK: - SUT
private extension ArchiveControllerTests {
    func makeSUT(
        inputResult: MockInputResult = .init(),
        permissionResult: MockPermissionResult = .init(),
        selectionResult: MockSelectionResult = .init(),
        throwError: Bool = false,
        archivesToLoad: [ArchiveFolder] = []
    ) -> (sut: ArchiveController, service: MockArchiveService, progressHandler: MockPurgeProgressHandler) {
        let progressHandler = MockPurgeProgressHandler()
        let service = MockArchiveService(throwError: throwError, archivesToLoad: archivesToLoad)
        let picker = MockSwiftPicker(
            inputResult: inputResult,
            permissionResult: permissionResult,
            selectionResult: selectionResult
        )
        let sut = ArchiveController(
            picker: picker,
            service: service,
            progressHandler: progressHandler
        )

        return (sut, service, progressHandler)
    }
}
