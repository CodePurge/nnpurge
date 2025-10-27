//
//  DefaultContextFactory.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import Foundation
import SwiftPicker

struct DefaultContextFactory: ContextFactory {
    func makePicker() -> any CommandLinePicker {
        return InteractivePicker()
    }

    func makeUserDefaults() -> any DerivedDataStore {
        return UserDefaults.standard
    }

    func makeDerivedDataManager(defaults: DerivedDataStore) -> any DerivedDataDelegate {
        return OldDerivedDataManager(
            userDefaults: defaults,
            folderLoader: DefaultFolderLoader(),
            fileManager: FileManager.default
        )
    }

    func makePackageCacheManager() -> any PackageCacheDelegate {
        return PackageCacheManager(
            folderLoader: DefaultFolderLoader(),
            fileManager: FileManager.default
        )
    }
}
