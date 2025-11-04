//
//  ArchiveService.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 11/4/25.
//

import Foundation

public protocol ArchiveService: PurgeService {
    func deleteAllArchives(progressHandler: PurgeProgressHandler?) throws
}

public extension ArchiveService {
    func deleteAllArchives() throws {
        try deleteAllArchives(progressHandler: nil)
    }

    func deleteAllFolders(progressHandler: PurgeProgressHandler?) throws {
        try deleteAllArchives(progressHandler: progressHandler)
    }
}
