//
//  TestFactory.swift
//  CodePurgeTesting
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Foundation
import CodePurgeKit

public func makePurgeFolder(name: String = "TestFolder", path: String = "/path/to/folder", size: Int = 1000) -> OldPurgeFolder {
    let url = URL(fileURLWithPath: path).appendingPathComponent(name)

    return .init(url: url, name: name, path: path, size: size)
}

public func makeArchiveFolder(name: String = "TestArchive.xcarchive", path: String = "/path/to/archives", creationDate: Date? = Date(), modificationDate: Date? = Date()) -> ArchiveFolder {
    let url = URL(fileURLWithPath: path).appendingPathComponent(name)

    return .init(url: url, name: name, path: path, creationDate: creationDate, modificationDate: modificationDate)
}

public struct MockPurgeFolder: PurgeFolder {
    public let url: URL
    public let name: String
    public let path: String
    public let creationDate: Date?
    public let modificationDate: Date?
    public let subfolders: [MockPurgeFolder]

    public init(name: String = "TestFolder", path: String = "/path/to/folder", creationDate: Date? = nil, modificationDate: Date? = nil, subfolders: [MockPurgeFolder] = []) {
        self.url = URL(fileURLWithPath: path).appendingPathComponent(name)
        self.name = name
        self.path = path
        self.creationDate = creationDate
        self.modificationDate = modificationDate
        self.subfolders = subfolders
    }

    public func getSize() -> Int64 {
        return 1000
    }
}
