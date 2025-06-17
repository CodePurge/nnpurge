//
//  MockUserDefaults.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

@testable import nnpurge

final class MockUserDefaults: UserDefaultsProtocol {
    private(set) var values: [String: Any] = [:]

    func string(forKey defaultName: String) -> String? {
        return values[defaultName] as? String
    }

    func set(_ value: Any?, forKey defaultName: String) {
        values[defaultName] = value
    }
}
