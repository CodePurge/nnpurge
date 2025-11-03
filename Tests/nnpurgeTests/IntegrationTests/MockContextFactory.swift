//
//  MockContextFactory.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import SwiftPicker
import CodePurgeKit
import SwiftPickerTesting
@testable import nnpurge

struct MockContextFactory {
    private let picker: MockSwiftPicker?
    private let derivedDataStore: any DerivedDataStore
    private let derivedDataService: MockDerivedDataService?

    init(
        picker: MockSwiftPicker? = nil,
        derivedDataStore: any DerivedDataStore = MockUserDefaults(),
        derivedDataService: MockDerivedDataService? = nil
    ) {
        self.picker = picker
        self.derivedDataStore = derivedDataStore
        self.derivedDataService = derivedDataService
    }
}


// MARK: - ContextFactory
extension MockContextFactory: ContextFactory {
    func makePicker() -> any CommandLinePicker {
        if let picker {
            return picker
        }

        fatalError("makePicker() not implemented")
    }

    func makeUserDefaults() -> DerivedDataStore {
        return derivedDataStore
    }

    func makeDerivedDataService(path: String) -> any DerivedDataService {
        if let derivedDataService {
            return derivedDataService
        }

        fatalError("makeDerivedDataService() not implemented")
    }
}
