//
//  MockArchiveService.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/4/25.
//

import Foundation
import CodePurgeKit
@testable import nnpurge

final class MockArchiveService: @unchecked Sendable, ArchiveService {
    private let throwError: Bool
    private let archivesToLoad: [ArchiveFolder]

    private(set) var didDeleteArchives = false
    private(set) var deletedArchives: [ArchiveFolder] = []
    private(set) var receivedProgressHandler: PurgeProgressHandler?

    init(throwError: Bool = false, archivesToLoad: [ArchiveFolder] = []) {
        self.throwError = throwError
        self.archivesToLoad = archivesToLoad
    }

    func loadArchives() throws -> [ArchiveFolder] {
        if throwError {
            throw NSError(domain: "TestError", code: 1)
        }

        return archivesToLoad
    }

    func deleteArchives(_ archives: [ArchiveFolder], progressHandler: PurgeProgressHandler?) throws {
        if throwError {
            throw NSError(domain: "TestError", code: 1)
        }

        didDeleteArchives = true
        receivedProgressHandler = progressHandler
        deletedArchives.append(contentsOf: archives)

        for (index, archive) in archives.enumerated() {
            progressHandler?.updateProgress(current: index + 1, total: archives.count, message: "Deleting \(archive.name)...")
        }
    }
}
