//
//  DefaultDerivedDataDelegate.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/5/25.
//

import Foundation

struct DefaultDerivedDataDelegate: DerivedDataDelegate {
    func deleteFolder(_ folder: DerivedDataFolder) throws {
        try deleteItem(at: folder.url)
    }

    func deleteItem(at url: URL) throws {
        try FileManager.default.trashItem(at: url, resultingItemURL: nil)
    }
}
