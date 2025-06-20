//
//  ContextFactory.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import SwiftPicker

/// Factory used to create dependencies for the `nnpurge` commands.
protocol ContextFactory {
    /// Returns a picker used to present interactive selections.
    func makePicker() -> Picker

    /// Returns a data store for persisting user configuration.
    func makeUserDefaults() -> DerivedDataStore

    /// Returns a manager responsible for handling DerivedData operations.
    func makeDerivedDataManager(defaults: DerivedDataStore) -> DerivedDataDelegate
}
