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
    private let derivedDataStore: any DerivedDataStore
    
    private let picker: MockSwiftPicker?
    
    init(derivedDataStore: any DerivedDataStore, picker: MockSwiftPicker?) {
        self.derivedDataStore = derivedDataStore
        self.picker = picker
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
        fatalError("makeDerivedDataService() not implemented")
    }
}
