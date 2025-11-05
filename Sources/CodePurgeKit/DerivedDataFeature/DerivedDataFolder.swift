//
//  DerivedDataFolder.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/5/25.
//

import Foundation

public struct DerivedDataFolder {
    public let url: URL
    public let name: String
    public let path: String
    public let creationDate: Date?
    public let modificationDate: Date?
    
    public init(url: URL, name: String, path: String, creationDate: Date?, modificationDate: Date?) {
        self.url = url
        self.name = name
        self.path = path
        self.creationDate = creationDate
        self.modificationDate = modificationDate
    }
}
