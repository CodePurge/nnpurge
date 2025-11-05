//
//  DefaultPackageCacheDelegate.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/5/25.
//

import Foundation

struct DefaultPackageCacheDelegate: PackageCacheDelegate {
    func deleteFolder(_ folder: PackageCacheFolder) throws {
        try FileManager.default.trashItem(at: folder.url, resultingItemURL: nil)
    }
}
