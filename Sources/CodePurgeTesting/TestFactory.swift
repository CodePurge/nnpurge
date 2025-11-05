//
//  TestFactory.swift
//  CodePurgeTesting
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Foundation
import CodePurgeKit

public func makeDerivedDataFolder(name: String = "TestFolder") -> DerivedDataFolder {
    let url = URL(fileURLWithPath: "/path/to/\(name)")
    
    return .init(url: url, name: name, path: url.path, creationDate: Date(), modificationDate: Date())
}

public func makeArchiveFolder(name: String = "TestArchive.xcarchive", path: String = "/path/to/archives", creationDate: Date? = Date(), modificationDate: Date? = Date()) -> ArchiveFolder {
    let url = URL(fileURLWithPath: path).appendingPathComponent(name)

    return .init(url: url, name: name, path: path, creationDate: creationDate, modificationDate: modificationDate, imageData: nil, uploadStatus: nil, versionNumber: nil)
}

public func makePackageCacheFolder(name: String = "TestPackage", path: String = "/path/to/package", branchId: String = "main", lastFetchedDate: String? = nil, creationDate: Date? = Date(), modificationDate: Date? = Date()) -> PackageCacheFolder {
    let url = URL(fileURLWithPath: path).appendingPathComponent(name)

    return .init(url: url, name: name, path: url.path, creationDate: creationDate, modificationDate: modificationDate, branchId: branchId, lastFetchedDate: lastFetchedDate)
}
