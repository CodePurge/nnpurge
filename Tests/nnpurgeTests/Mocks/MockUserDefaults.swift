//
//  MockUserDefaults.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

@testable import nnpurge

/// Lightweight `UserDefaults` replacement for tests.
final class MockUserDefaults: DerivedDataStore {
    /// Storage for key/value pairs set during testing.
    private(set) var values: [String: Any] = [:]

    /// Returns the stored string for the specified key.
    func string(forKey defaultName: String) -> String? {
        return values[defaultName] as? String
    }

    /// Stores a value for the specified key.
    func set(_ value: Any?, forKey defaultName: String) {
        values[defaultName] = value
    }
}
