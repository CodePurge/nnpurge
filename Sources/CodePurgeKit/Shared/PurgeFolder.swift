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
    public let modificationDate: Date?
    public let creationDate: Date?

    public init(url: URL, name: String, path: String, size: Int, modificationDate: Date? = nil, creationDate: Date? = nil) {
        self.url = url
        self.name = name
        self.path = path
        self.size = size
        self.modificationDate = modificationDate
        self.creationDate = creationDate
    }
}


// MARK: - Stale Filtering
public extension PurgeFolder {
    static func filterStale(_ folders: [PurgeFolder], olderThanDays days: Int) -> [PurgeFolder] {
        let calendar = Calendar.current
        let threshold = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()

        return folders.filter { folder in
            if folder.modificationDate == nil && folder.creationDate == nil {
                return true
            } else if let modificationDate = folder.modificationDate {
                return modificationDate < threshold
            } else if folder.modificationDate == nil, let creationDate = folder.creationDate {
                return creationDate < threshold
            }

            return false
        }
    }
}


// MARK: - Dependency Filtering
public extension PurgeFolder {
    static func filterByDependencies(_ folders: [PurgeFolder], identities: [String]) -> [PurgeFolder] {
        let lowercaseIdentities = Set(identities.map { $0.lowercased() })

        return folders.filter { folder in
            guard let packageName = folder.packageName else { return false }
            return lowercaseIdentities.contains(packageName.lowercased())
        }
    }

    private var packageName: String? {
        guard let lastDashIndex = name.lastIndex(of: "-") else { return nil }
        return String(name[..<lastDashIndex])
    }
}
