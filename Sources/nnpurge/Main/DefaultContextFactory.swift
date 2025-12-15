//
//  DefaultContextFactory.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import Foundation
import CodePurgeKit
import SwiftPickerKit

struct DefaultContextFactory: ContextFactory {
    func makePicker() -> any PurgePicker {
        return SwiftPicker()
    }

    func makeUserDefaults() -> any DerivedDataStore {
        return UserDefaults.standard
    }

    func makeDerivedDataService(path: String) -> any DerivedDataService {
        return DerivedDataManager(path: path)
    }

    func makePackageCacheService() -> any PackageCacheService {
        return PackageCacheManager()
    }

    func makeArchiveService() -> any ArchiveService {
        return ArchiveManager()
    }
}


// MARK: - Extension Depdencies
extension SwiftPicker: PurgePicker { }
extension UserDefaults: DerivedDataStore { }
