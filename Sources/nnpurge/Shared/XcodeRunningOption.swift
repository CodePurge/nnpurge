//
//  XcodeRunningOption.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/5/25.
//

import SwiftPicker

enum XcodeRunningOption: CaseIterable {
    case proceedAnyway, waitUntilUserClosesXcode, cancel
}

extension XcodeRunningOption: DisplayablePickerItem {
    var displayName: String {
        switch self {
        case .proceedAnyway:
            return "Proceed anyway (may cause issues)"
        case .waitUntilUserClosesXcode:
            return "Wait until I close Xcode manually"
        case .cancel:
            return "Cancel operation"
        }
    }
}
