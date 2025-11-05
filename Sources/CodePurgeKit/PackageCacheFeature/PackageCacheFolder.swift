//
//  PackageCacheFolder.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/5/25.
//

import Foundation

public struct PackageCacheFolder {
    public let url: URL
    public let name: String
    public let path: String
    public let creationDate: Date?
    public let modificationDate: Date?
    
    public let branchId: String
    public let lastFetchedDate: String?
    
    public init(
        url: URL,
        name: String,
        path: String,
        creationDate: Date?,
        modificationDate: Date?,
        branchId: String,
        lastFetchedDate: String?
    ) {
        self.url = url
        self.name = name
        self.path = path
        self.creationDate = creationDate
        self.modificationDate = modificationDate
        self.branchId = branchId
        self.lastFetchedDate = lastFetchedDate
    }
}
