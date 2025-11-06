//
//  FileSystemDelegate.swift
//  Nnpurge
//
//  Created by Nikolai Nobadi on 11/4/25.
//

import Foundation

struct DefaultFileSystemDelegate: FileSystemDelegate {
    var currentDirectoryPath: String {
        return FileManager.default.currentDirectoryPath
    }

    func fileExists(atPath path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }

    func appendingPathComponent(_ path: String, _ component: String) -> String {
        return (path as NSString).appendingPathComponent(component)
    }

    func readData(atPath path: String) throws -> Data {
        return try Data(contentsOf: URL(fileURLWithPath: path))
    }
}

public enum PackageCacheError: Error, Equatable, CustomStringConvertible {
    case packageResolvedNotFound(path: String)
    case xcodeIsRunning
    case xcodeFailedToClose

    public var description: String {
        switch self {
        case .packageResolvedNotFound(let path):
            return "Package.resolved not found in: \(path)"
        case .xcodeIsRunning:
            return "Xcode is currently running"
        case .xcodeFailedToClose:
            return "Xcode failed to close"
        }
    }
}
