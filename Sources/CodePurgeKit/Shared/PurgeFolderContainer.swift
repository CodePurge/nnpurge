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
        return folder.getSize()
    }
    
    func getFilePath(named name: String) -> String? {
        return try? folder.file(named: name).path
    }
    
    func readFileData(fileName: String) -> Data? {
        return try? folder.file(named: fileName).read()
    }
    
    func getSubfolder(named name: String) -> PurgeFolderContainer? {
        guard let subfolder = try? folder.subfolder(named: name) else {
            return nil
        }
        
        return .init(folder: subfolder)
    }
    
    func getImageData() -> Data? {
        guard
            let productsFolder = getSubfolder(named: "Products"),
            let applicationFolder = productsFolder.getSubfolder(named: "Applications"),
            let appFolder = applicationFolder.subfolders.first
        else {
            return nil
        }
        
        return appFolder.readFileData(fileName: "AppIcon60x60@2x.png")
    }
}


// MARK: - Extension Dependencies
private extension Folder {
    func getSize() -> Int64 {
        var totalSize: Int64 = 0

        let fileEnumerator = FileManager.default.enumerator(at: URL(fileURLWithPath: path), includingPropertiesForKeys: [.fileSizeKey], options: .skipsHiddenFiles)
        
        for case let fileURL as URL in fileEnumerator! {
            do {
                let fileAttributes = try fileURL.resourceValues(forKeys: [.fileSizeKey])
                if let fileSize = fileAttributes.fileSize {
                    totalSize += Int64(fileSize)
                }
            } catch {
                print("Error getting file size for \(fileURL): \(error)")
            }
        }
        
        return totalSize
    }
}
