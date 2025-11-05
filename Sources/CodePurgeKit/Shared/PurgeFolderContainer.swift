//
//  PurgeFolderContainer.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/4/25.
//

import Files
import Foundation

struct PurgeFolderContainer {
    private let folder: Folder
    
    init(folder: Folder) {
        self.folder = folder
    }
}


// MARK: - PurgeFolder
extension PurgeFolderContainer: PurgeFolder {
    var url: URL {
        return folder.url
    }
    
    var name: String {
        return folder.name
    }
    
    var path: String {
        return folder.path
    }
    
    var creationDate: Date? {
        return folder.creationDate
    }
    
    var modificationDate: Date? {
        return folder.modificationDate
    }
    
    var subfolders: [PurgeFolderContainer] {
        return folder.subfolders.map({ .init(folder: $0) })
    }
    
    func getSize() -> Int64 {
        return 0 // TODO: - 
    }
    
    func getFilePath(named name: String) -> String? {
        return try? folder.file(named: name).path
    }
}
