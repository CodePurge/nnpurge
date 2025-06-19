//
//  DefaultContextFactory.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import Foundation
import SwiftPicker

struct DefaultContextFactory: ContextFactory {
    func makePicker() -> Picker {
        return SwiftPicker()
    }
    
    func makeUserDefaults() -> DerivedDataStore {
        return UserDefaults.standard
    }

    func makeDerivedDataManager(defaults: DerivedDataStore) -> DerivedDataDelegate {
        return DerivedDataManager(
            userDefaults: defaults,
            folderLoader: DefaultFolderLoader(),
            fileManager: FileManager.default
        )
    }
}
