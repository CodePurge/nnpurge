//
//  ArchiveFolder.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/4/25.
//

import Foundation

public struct ArchiveFolder {
    public let url: URL
    public let name: String
    public let path: String
    public let creationDate: Date?
    public let modificationDate: Date?
    
    public var imageData: Data?
    public var uploadStatus: String?
    public var versionNumber: String?
    
    public init(url: URL, name: String, path: String, creationDate: Date?, modificationDate: Date?, imageData: Data?, uploadStatus: String?, versionNumber: String?) {
        self.url = url
        self.name = name
        self.path = path
        self.creationDate = creationDate
        self.modificationDate = modificationDate
        self.imageData = imageData
        self.uploadStatus = uploadStatus
        self.versionNumber = versionNumber
    }
}
