//
//  DefaultDerivedDataDelegate.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/5/25.
//

import Foundation

struct DefaultDerivedDataDelegate: DerivedDataDelegate {
    func deleteFolder(_ folder: DerivedDataFolder) throws {
        try FileManager.default.trashItem(at: folder.url, resultingItemURL: nil)
    }
}
