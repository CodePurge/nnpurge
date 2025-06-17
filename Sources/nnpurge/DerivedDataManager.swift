import Files
import Foundation

enum DerivedDataManager {
    static func loadDerivedDataFolders() throws -> [Folder] {
        let defaultPath = "~/Library/Developer/Xcode/DerivedData"
        let savedPath = UserDefaults.standard.string(forKey: "derivedDataPath") ?? defaultPath
        let expandedPath = NSString(string: savedPath).expandingTildeInPath
        return try Folder(path: expandedPath).subfolders.map { $0 }
    }

    static func moveFoldersToTrash(_ folders: [Folder]) throws {
        for folder in folders {
            print("Moving \(folder.name) to Trash")
            try FileManager.default.trashItem(at: folder.url, resultingItemURL: nil)
            print("\(folder.name) successfully moved to Trash")
        }
    }
}
