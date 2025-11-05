//
//  DeleteDerivedDataTests.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Testing
import Foundation
import CodePurgeKit
import CodePurgeTesting
import SwiftPickerTesting
@testable import nnpurge

@MainActor
final class DeleteDerivedDataTests {
    @Test("Deletes all derived data when all flag passed", arguments: ["-a", "--all"])
    func deletesAllDerivedDataWhenAllFlagPassed(deleteAllArg: String) throws {
        let folders = [
            makeDerivedDataFolder(name: "Project1-abcd1234"),
            makeDerivedDataFolder(name: "Project2-efgh5678"),
            makeDerivedDataFolder(name: "Project3-ijkl9012")
        ]
        let (factory, service) = makeSUT(foldersToLoad: folders)

        try Nnpurge.testRun(contextFactory: factory, args: ["derived-data", "delete", deleteAllArg])

        #expect(service.didDeleteAllDerivedData)
        #expect(service.deletedDerivedDataFolders.count == folders.count)
    }

    @Test("Deletes all derived data when option is selected from picker input")
    func deletesAllDerivedDataFromPickerInput() throws {
        let folders = [
            makeDerivedDataFolder(name: "Project1-abcd1234"),
            makeDerivedDataFolder(name: "Project2-efgh5678")
        ]
        let (factory, service) = makeSUT(
            foldersToLoad: folders,
            selectionResult: .init(defaultIndex: 0)
        )

        try Nnpurge.testRun(contextFactory: factory, args: ["derived-data", "delete"])

        #expect(service.didDeleteAllDerivedData)
        #expect(service.deletedDerivedDataFolders.count == folders.count)
    }

    @Test("Deletes selected folders when selectFolders option chosen")
    func deletesSelectedFoldersWhenSelectFoldersOptionChosen() throws {
        let folder1 = makeDerivedDataFolder(name: "Project1-abcd1234")
        let folder2 = makeDerivedDataFolder(name: "Project2-efgh5678")
        let folder3 = makeDerivedDataFolder(name: "Project3-ijkl9012")
        let folders = [folder1, folder2, folder3]
        let selectedIndices = [0, 2]
        let (factory, service) = makeSUT(
            foldersToLoad: folders,
            selectionResult: .init(
                singleSelectionType: .ordered([1]),
                multiSelectionType: .ordered([selectedIndices])
            )
        )

        try Nnpurge.testRun(contextFactory: factory, args: ["derived-data", "delete"])

        #expect(service.didDeleteAllDerivedData)
        #expect(service.deletedDerivedDataFolders.count == 2)
        #expect(service.deletedDerivedDataFolders.contains(where: { $0.name == folder1.name }))
        #expect(service.deletedDerivedDataFolders.contains(where: { $0.name == folder3.name }))
    }

    @Test("Deletes no folders when user selects none during folder selection")
    func deletesNoFoldersWhenUserSelectsNoneDuringFolderSelection() throws {
        let folders = [
            makeDerivedDataFolder(name: "Project1-abcd1234"),
            makeDerivedDataFolder(name: "Project2-efgh5678"),
            makeDerivedDataFolder(name: "Project3-ijkl9012")
        ]
        let (factory, service) = makeSUT(
            foldersToLoad: folders,
            selectionResult: .init(
                singleSelectionType: .ordered([1]),
                multiSelectionType: .ordered([[]])
            )
        )

        try Nnpurge.testRun(contextFactory: factory, args: ["derived-data", "delete"])

        #expect(service.didDeleteAllDerivedData)
        #expect(service.deletedDerivedDataFolders.isEmpty)
    }
}


// MARK: - SUT
private extension DeleteDerivedDataTests {
    func makeSUT(foldersToLoad: [DerivedDataFolder] = [], selectionResult: MockSelectionResult = .init()) -> (factory: MockContextFactory, service: MockPurgeService) {
        let store = MockUserDefaults()
        let service = MockPurgeService(derivedDataFoldersToLoad: foldersToLoad)
        let picker = makePicker(selectionResult: selectionResult)
        let factory = MockContextFactory(
            picker: picker,
            derivedDataStore: store,
            derivedDataService: service
        )

        return (factory, service)
    }

    func makePicker(selectionResult: MockSelectionResult) -> MockSwiftPicker {
        return MockSwiftPicker(
            permissionResult: .init(grantByDefault: true, type: .ordered([])),
            selectionResult: selectionResult
        )
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
