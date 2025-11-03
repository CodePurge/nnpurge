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
    @Test("Deletes all derived data using")
    func deletesAllDerivedData() throws {
        let picker = MockSwiftPicker()
        let store = MockUserDefaults()
        let factory = MockContextFactory(derivedDataStore: store, picker: picker)
        
        try Nnpurge.testRun(contextFactory: factory, args: ["derived-data", "delete", "--all"])
    }
}
