//
//  ContextFactory.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import SwiftPicker

protocol ContextFactory {
    func makePicker() -> any CommandLinePicker
    func makeUserDefaults() -> any DerivedDataStore
    func makeDerivedDataManager(defaults: DerivedDataStore) -> any DerivedDataDelegate
    func makePackageCacheManager() -> any PackageCacheDelegate
}
