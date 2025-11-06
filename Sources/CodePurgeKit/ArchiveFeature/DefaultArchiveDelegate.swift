//
//  DefaultArchiveDelegate.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/4/25.
//

import Foundation

struct DefaultArchiveDelegate: ArchiveDelegate {
    func deleteArchive(_ archive: ArchiveFolder) throws {
        try deleteItem(at: archive.url)
    }

    func deleteItem(at url: URL) throws {
        try FileManager.default.trashItem(at: url, resultingItemURL: nil)
    }
    
    func parseFolderPList(_ folder: any PurgeFolder) -> [String : Any]? {
        guard let path = folder.getFilePath(named: "Info.plist"),
              let data = FileManager.default.contents(atPath: path)
        else {
            print("Failed to read data from plist path")
            return nil
        }
        
        do {
            let plistData = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            guard let dictionary = plistData as? [String: Any] else {
                print("Failed to cast plist data to [String: Any]")
                return nil
            }
            return dictionary
        } catch {
            print("Error parsing plist: \(error)")
            return nil
        }
    }
}
