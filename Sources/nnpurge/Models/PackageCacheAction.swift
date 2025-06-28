//
//  PackageCacheAction.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import SwiftPicker

/// Actions available when choosing how to delete cached package repositories.
enum PackageCacheAction: CaseIterable {
    /// Delete every folder inside the Swift Package cache.
    case deleteAll
    /// Select specific repositories to delete.
    case deleteSelectFolder
}

extension PackageCacheAction: DisplayablePickerItem {
    /// Title shown when presenting options to the user.
    var displayName: String {
        switch self {
        case .deleteAll:
            return "Delete all package repositories."
        case .deleteSelectFolder:
            return "Delete selected package repositories"
        }
    }
}
