//
//  ContextFactory.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import SwiftPicker
import CodePurgeKit

protocol ContextFactory {
    func makePicker() -> any CommandLinePicker
    func makeUserDefaults() -> any DerivedDataStore
    func makeDerivedDataService() -> any DerivedDataService
    func makeDerivedDataManager(defaults: DerivedDataStore) -> any DerivedDataDelegate
    func makePackageCacheManager() -> any PackageCacheDelegate
}
