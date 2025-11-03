//
//  DeleteDerivedDataTests.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Testing
import CodePurgeTesting
import SwiftPickerTesting
@testable import nnpurge

@MainActor
final class DeleteDerivedDataTests {
    @Test("Deletes all derived data when all flag passed", arguments: ["-a", "--all"])
    func deletesAllDerivedDataWhenAllFlagPassed(deleteAllArg: String) throws {
        let picker = makePicker()
        let store = MockUserDefaults()
        let service = MockDerivedDataService()
        let factory = MockContextFactory(picker: picker, derivedDataStore: store, derivedDataService: service)

        try Nnpurge.testRun(contextFactory: factory, args: ["derived-data", "delete", deleteAllArg])

        #expect(service.didDeleteAllDerivedData)
    }
    
    @Test("Deletes all derived data when option is selected from picker input")
    func deletesAllDerivedDataFromPickerInput() throws {
        let store = MockUserDefaults()
        let service = MockDerivedDataService()
        let picker = makePicker(selectionResult: .init(defaultIndex: 0))
        let factory = MockContextFactory(picker: picker, derivedDataStore: store, derivedDataService: service)

        try Nnpurge.testRun(contextFactory: factory, args: ["derived-data", "delete"])

        #expect(service.didDeleteAllDerivedData)
    }

    @Test("Deletes selected folders when selectFolders option chosen")
    func deletesSelectedFoldersWhenSelectFoldersOptionChosen() throws {
        let folder1 = makePurgeFolder(name: "Project1-abcd1234")
        let folder2 = makePurgeFolder(name: "Project2-efgh5678")
        let folder3 = makePurgeFolder(name: "Project3-ijkl9012")
        let folders = [folder1, folder2, folder3]
        let selectedIndices = [0, 2]
        let store = MockUserDefaults()
        let service = MockDerivedDataService(foldersToLoad: folders)
        let picker = makePicker(
            selectionResult: .init(
                singleSelectionType: .ordered([1]),
                multiSelectionType: .ordered([selectedIndices])
            )
        )
        let factory = MockContextFactory(picker: picker, derivedDataStore: store, derivedDataService: service)

        try Nnpurge.testRun(contextFactory: factory, args: ["derived-data", "delete"])

        #expect(!service.didDeleteAllDerivedData)
        #expect(service.deletedFolders.count == 2)
        #expect(service.deletedFolders.contains(where: { $0.name == folder1.name }))
        #expect(service.deletedFolders.contains(where: { $0.name == folder3.name }))
    }
}


// MARK: -
private extension DeleteDerivedDataTests {
    func makePicker(selectionResult: MockSelectionResult = .init()) -> MockSwiftPicker {
        return .init(
            permissionResult: .init(grantByDefault: true, type: .ordered([])),
            selectionResult: selectionResult
        )
    }
}
