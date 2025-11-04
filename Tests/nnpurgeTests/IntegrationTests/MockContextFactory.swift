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
    private let purgeService: MockPurgeService?

    init(
        picker: MockSwiftPicker? = nil,
        derivedDataStore: any DerivedDataStore = MockUserDefaults(),
        purgeService: MockPurgeService? = nil
    ) {
        self.picker = picker
        self.derivedDataStore = derivedDataStore
        self.purgeService = purgeService
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

        fatalError("makePicker() not implemented")
    }

    func makeUserDefaults() -> DerivedDataStore {
        return derivedDataStore
    }

    func makeDerivedDataService(path: String) -> any DerivedDataService {
        if let purgeService {
            return purgeService
        }

        fatalError("makeDerivedDataService() not implemented")
    }

    func makePackageCacheService() -> any PackageCacheService {
        if let purgeService {
            return purgeService
        }

        return PackageCacheManager()
    }
}
