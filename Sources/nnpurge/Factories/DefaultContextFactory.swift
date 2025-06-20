//
//  DefaultContextFactory.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import Foundation
import SwiftPicker

/// Default production implementation of ``ContextFactory``.
struct DefaultContextFactory: ContextFactory {
    /// Returns an interactive picker implementation.
    func makePicker() -> Picker {
        return SwiftPicker()
    }

    /// Returns ``UserDefaults.standard`` as the data store.
    func makeUserDefaults() -> DerivedDataStore {
        return UserDefaults.standard
    }

    /// Creates a ``DerivedDataManager`` with default dependencies.
    func makeDerivedDataManager(defaults: DerivedDataStore) -> DerivedDataDelegate {
        return DerivedDataManager(
            userDefaults: defaults,
            folderLoader: DefaultFolderLoader(),
            fileManager: FileManager.default
        )
    }
}
