//
//  DeleteOption.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 10/26/25.
//

import SwiftPicker

enum DeleteOption: CaseIterable {
    case deleteAll
    case selectFolders
}


// MARK: - DisplayablePickerItem
extension DeleteOption: DisplayablePickerItem {
    var displayName: String {
        switch self {
        case .deleteAll:
            return "Delete all derived data folders"
        case .selectFolders:
            return "Select specific folders to delete"
        }
    }
}
