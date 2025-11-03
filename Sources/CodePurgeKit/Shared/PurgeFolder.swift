//
//  PurgeFolder.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 10/26/25.
//

import Foundation

public struct PurgeFolder {
    public let url: URL
    public let size: Int
    public let name: String
    public let path: String

    public init(url: URL, name: String, path: String, size: Int) {
        self.url = url
        self.name = name
        self.path = path
        self.size = size
    }
}
