//
//  PackageCacheAction.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import SwiftPicker

enum PackageCacheAction: CaseIterable {
    case deleteAll
    case deleteSelectFolder
    case openFolder
}


// MARK: - DisplayablePickerItem
extension PackageCacheAction: DisplayablePickerItem {
    var displayName: String {
        switch self {
        case .deleteAll:
            return "Delete all package repositories."
        case .deleteSelectFolder:
            return "Delete selected package repositories"
        case .openFolder:
            return "Open the package repositories folder"
        }
    }
}
