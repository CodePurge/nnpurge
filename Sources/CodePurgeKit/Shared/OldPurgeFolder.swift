//
//  OldPurgeFolder.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 10/26/25.
//

import Foundation

public protocol PurgeFolder {
    var url: URL { get }
    var name: String { get }
    var path: String { get }
    var subfolders: [Self] { get }
    var creationDate: Date? { get }
    var modificationDate: Date? { get }
    
    func getSize() -> Int64
    func getFilePath(named name: String) -> String?
}
