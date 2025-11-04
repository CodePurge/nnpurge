//
//  MockProgressHandler.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Foundation
@testable import CodePurgeKit

// Primary mock for PurgeProgressHandler
final class MockPurgeProgressHandler: @unchecked Sendable, PurgeProgressHandler {
    private(set) var deletedFolders: [PurgeFolder] = []

    func didDeleteFolder(_ folder: PurgeFolder) {
        deletedFolders.append(folder)
    }
}

// Type alias for backward compatibility with existing tests
typealias MockProgressHandler = MockPurgeProgressHandler
