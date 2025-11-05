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
    private let derivedDataService: (any DerivedDataService)?
    private let packageCacheService: (any PackageCacheService)?

    init(picker: MockSwiftPicker? = nil, derivedDataStore: any DerivedDataStore = MockUserDefaults(), derivedDataService: (any DerivedDataService)? = nil, packageCacheService: (any PackageCacheService)? = nil) {
        self.picker = picker
        self.derivedDataStore = derivedDataStore
        self.derivedDataService = derivedDataService
        self.packageCacheService = packageCacheService
    }
}


// MARK: - ContextFactory
extension MockContextFactory: ContextFactory {
    func makeArchiveService() -> any ArchiveService {
        fatalError() // TODO: -
    }
    
    func makePicker() -> any CommandLinePicker {
        if let picker {
            return picker
        }

        return MockSwiftPicker()
    }

    func makeUserDefaults() -> DerivedDataStore {
        return derivedDataStore
    }

    func makeDerivedDataService(path: String) -> any DerivedDataService {
        if let derivedDataService {
            return derivedDataService
        }

        return MockPurgeService()
    }

    func makePackageCacheService() -> any PackageCacheService {
        if let packageCacheService {
            return packageCacheService
        }

        return MockPurgeService()
    }
}
