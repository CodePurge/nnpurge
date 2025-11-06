//
//  ArchiveService.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 11/4/25.
//

import Foundation

public protocol ArchiveService {
    func loadArchives() throws -> [ArchiveFolder]
    func deleteArchives(_ archives: [ArchiveFolder], force: Bool, progressHandler: PurgeProgressHandler?) throws
    func closeXcodeAndVerify(timeout: TimeInterval) throws
}
