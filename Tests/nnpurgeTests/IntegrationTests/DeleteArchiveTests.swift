//
//  DeleteArchiveTests.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/5/25.
//

import Testing
import Foundation
import CodePurgeKit
import CodePurgeTesting
import SwiftPickerTesting
@testable import nnpurge

@MainActor
final class DeleteArchiveTests {
    @Test("Deletes all archives when all flag passed", arguments: ["-a", "--all"])
    func deletesAllArchivesWhenAllFlagPassed(deleteAllArg: String) throws {
        let archives = [
            makeArchiveFolder(name: "Archive1.xcarchive"),
            makeArchiveFolder(name: "Archive2.xcarchive"),
            makeArchiveFolder(name: "Archive3.xcarchive")
        ]
        let (factory, service) = makeSUT(archivesToLoad: archives)

        try Nnpurge.testRun(contextFactory: factory, args: ["archive", "delete", deleteAllArg])

        #expect(service.didDeleteArchives)
        #expect(service.deletedArchives.count == archives.count)
    }

    @Test("Deletes all archives when option is selected from picker input")
    func deletesAllArchivesFromPickerInput() throws {
        let archives = [
            makeArchiveFolder(name: "Archive1.xcarchive"),
            makeArchiveFolder(name: "Archive2.xcarchive")
        ]
        let (factory, service) = makeSUT(
            archivesToLoad: archives,
            selectionResult: .init(defaultIndex: 0)
        )

        try Nnpurge.testRun(contextFactory: factory, args: ["archive", "delete"])

        #expect(service.didDeleteArchives)
        #expect(service.deletedArchives.count == archives.count)
    }

    @Test("Deletes stale archives when delete stale option chosen")
    func deletesStaleArchivesWhenDeleteStaleOptionChosen() throws {
        let oldDate = Calendar.current.date(byAdding: .day, value: -40, to: Date())
        let recentDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())
        let staleArchive1 = makeArchiveFolder(name: "StaleArchive1.xcarchive", modificationDate: oldDate)
        let staleArchive2 = makeArchiveFolder(name: "StaleArchive2.xcarchive", modificationDate: oldDate)
        let recentArchive = makeArchiveFolder(name: "RecentArchive.xcarchive", modificationDate: recentDate)
        let (factory, service) = makeSUT(
            archivesToLoad: [staleArchive1, staleArchive2, recentArchive],
            selectionResult: .init(defaultIndex: 1)
        )

        try Nnpurge.testRun(contextFactory: factory, args: ["archive", "delete"])

        #expect(service.didDeleteArchives)
        #expect(service.deletedArchives.count == 2)
        #expect(service.deletedArchives.contains(where: { $0.name == staleArchive1.name }))
        #expect(service.deletedArchives.contains(where: { $0.name == staleArchive2.name }))
    }

    @Test("Deletes selected archives when select folders option chosen")
    func deletesSelectedArchivesWhenSelectFoldersOptionChosen() throws {
        let archive1 = makeArchiveFolder(name: "Archive1.xcarchive")
        let archive2 = makeArchiveFolder(name: "Archive2.xcarchive")
        let archive3 = makeArchiveFolder(name: "Archive3.xcarchive")
        let archives = [archive1, archive2, archive3]
        let selectedIndices = [0, 2]
        let (factory, service) = makeSUT(
            archivesToLoad: archives,
            selectionResult: .init(
                singleSelectionType: .ordered([2]),
                multiSelectionType: .ordered([selectedIndices])
            )
        )

        try Nnpurge.testRun(contextFactory: factory, args: ["archive", "delete"])

        #expect(service.didDeleteArchives)
        #expect(service.deletedArchives.count == 2)
        #expect(service.deletedArchives.contains(where: { $0.name == archive1.name }))
        #expect(service.deletedArchives.contains(where: { $0.name == archive3.name }))
    }

    @Test("Deletes no archives when user selects none during archive selection")
    func deletesNoArchivesWhenUserSelectsNoneDuringArchiveSelection() throws {
        let archives = [
            makeArchiveFolder(name: "Archive1.xcarchive"),
            makeArchiveFolder(name: "Archive2.xcarchive"),
            makeArchiveFolder(name: "Archive3.xcarchive")
        ]
        let (factory, service) = makeSUT(
            archivesToLoad: archives,
            selectionResult: .init(
                singleSelectionType: .ordered([2]),
                multiSelectionType: .ordered([[]])
            )
        )

        try Nnpurge.testRun(contextFactory: factory, args: ["archive", "delete"])

        #expect(service.didDeleteArchives)
        #expect(service.deletedArchives.isEmpty)
    }
}


// MARK: - SUT
private extension DeleteArchiveTests {
    func makeSUT(
        archivesToLoad: [ArchiveFolder] = [],
        selectionResult: MockSelectionResult = .init()
    ) -> (factory: MockContextFactory, service: MockArchiveService) {
        let service = MockArchiveService(archivesToLoad: archivesToLoad)
        let picker = makePicker(selectionResult: selectionResult)
        let factory = MockContextFactory(
            picker: picker,
            archiveService: service
        )

        return (factory, service)
    }

    func makePicker(selectionResult: MockSelectionResult) -> MockSwiftPicker {
        return .init(
            permissionResult: .init(grantByDefault: true, type: .ordered([])),
            selectionResult: selectionResult
        )
    }
}
