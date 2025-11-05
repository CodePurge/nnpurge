//
//  ArchiveService.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 11/4/25.
//

public protocol ArchiveService {
    func loadArchives() throws -> [ArchiveFolder]
    func deleteArchives(_ archives: [ArchiveFolder], progressHandler: PurgeProgressHandler?) throws
}
