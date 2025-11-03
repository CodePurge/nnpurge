//
//  DefaultContextFactory.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import Foundation
import SwiftPicker
import CodePurgeKit

struct DefaultContextFactory: ContextFactory {
    func makePicker() -> any CommandLinePicker {
        return InteractivePicker()
    }

    func makeUserDefaults() -> any DerivedDataStore {
        return UserDefaults.standard
    }

    func makeDerivedDataService() -> any DerivedDataService {
        let defaults = makeUserDefaults()
        let defaultPath = "~/Library/Developer/Xcode/DerivedData"
        let savedPath = defaults.string(forKey: "derivedDataPath") ?? defaultPath
        let expandedPath = NSString(string: savedPath).expandingTildeInPath

        return DerivedDataManager(path: expandedPath)
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
