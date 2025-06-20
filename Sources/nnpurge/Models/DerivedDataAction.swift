//
//  DerivedDataAction.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import SwiftPicker

/// Actions available when choosing how to delete DerivedData.
enum DerivedDataAction: CaseIterable {
    /// Delete every folder inside the DerivedData directory.
    case deleteAll
    /// Select specific folders to delete.
    case deleteSelectFolder
}

extension DerivedDataAction: DisplayablePickerItem {
    /// Title shown when presenting options to the user.
    var displayName: String {
        switch self {
        case .deleteAll:
            return "Delete all derived data folders."
        case .deleteSelectFolder:
            return "Delete selected derived data folders"
        }
    }
}
