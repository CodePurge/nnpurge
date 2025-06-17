//
//  DerivedDataAction.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import SwiftPicker

enum DerivedDataAction: CaseIterable {
    case deleteAll
    case deleteSelectFolder
}

extension DerivedDataAction: DisplayablePickerItem {
    var displayName: String {
        switch self {
        case .deleteAll:
            return "Delete all derived data folders."
        case .deleteSelectFolder:
            return "Delete selected derived data folders"
        }
    }
}
