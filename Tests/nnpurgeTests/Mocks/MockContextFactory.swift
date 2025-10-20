//
//  MockContextFactory.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import SwiftPicker
@testable import nnpurge

struct MockContextFactory: ContextFactory {
    let userDefaults = MockUserDefaults()

    func makePicker() -> CommandLinePicker {
        fatalError("makePicker() not implemented")
    }

    func makeUserDefaults() -> DerivedDataStore {
        return userDefaults
    }

    func makeDerivedDataManager(defaults: DerivedDataStore) -> DerivedDataDelegate {
        fatalError("makeDerivedDataManager(defaults:) not implemented")
    }

    func makePackageCacheManager() -> PackageCacheDelegate {
        fatalError("makePackageCacheManager() not implemented")
    }
}
