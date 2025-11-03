//
//  DeleteOption+DisplayablePickerItem.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import SwiftPicker

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
