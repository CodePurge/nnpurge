//
//  DefaultArchiveDelegate.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/4/25.
//

import Foundation

struct DefaultArchiveDelegate: ArchiveDelegate {
    func deleteArchive(_ archive: ArchiveFolder) throws {
        try FileManager.default.trashItem(at: archive.url, resultingItemURL: nil)
    }
}
