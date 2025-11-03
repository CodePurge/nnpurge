//
//  DeleteDerivedDataTests.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Testing
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
