//
//  DerivedDataStore.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import Foundation

/// Lightweight abstraction over ``UserDefaults`` used for storing configuration.
protocol DerivedDataStore {
    /// Retrieves a stored string value for the given key.
    func string(forKey defaultName: String) -> String?

    /// Persists a value for the given key.
    func set(_ value: Any?, forKey defaultName: String)
}

extension UserDefaults: DerivedDataStore {}
