//
//  MockArchiveDelegate.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 11/4/25.
//

import Foundation
@testable import CodePurgeKit

final class MockArchiveDelegate: ArchiveDelegate, @unchecked Sendable {
    private let throwError: Bool

    private(set) var deletedArchives: [ArchiveFolder] = []

    init(throwError: Bool = false) {
        self.throwError = throwError
    }

    func deleteArchive(_ archive: ArchiveFolder) throws {
        if throwError {
            throw NSError(domain: "MockArchiveDelegate", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        }
        deletedArchives.append(archive)
    }
}
