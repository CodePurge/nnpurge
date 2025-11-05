//
//  MockPurgeFolder.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/5/25.
//

import Foundation
import CodePurgeKit

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

    public init(name: String, url: URL, path: String, creationDate: Date? = nil, modificationDate: Date? = nil, subfolders: [MockPurgeFolder] = []) {
        self.url = url
        self.name = name
        self.path = path
        self.creationDate = creationDate
        self.modificationDate = modificationDate
        self.subfolders = subfolders
    }

    public init(folder: PackageCacheFolder) {
        self.url = folder.url
        self.name = folder.name
        self.path = folder.path
        self.creationDate = folder.creationDate
        self.modificationDate = folder.modificationDate
        self.subfolders = []
    }

    public func getSize() -> Int64 {
        return 1000
    }
    
    public func getFilePath(named name: String) -> String? {
        return nil
    }
    
    public func getImageData() -> Data? {
        return nil
    }
    
    public func readFileData(fileName: String) -> Data? {
        return nil
    }
    
    public func getSubfolder(named name: String) -> MockPurgeFolder? {
        return nil
    }
}
