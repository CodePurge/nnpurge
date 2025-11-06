//
//  XcodeRunningOption.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/5/25.
//

import SwiftPicker

enum XcodeRunningOption: CaseIterable {
    case proceedAnyway, closeXcodeAndProceed, cancel
}

extension XcodeRunningOption: DisplayablePickerItem {
    var displayName: String {
        switch self {
        case .proceedAnyway:
            return "Proceed anyway (may cause issues)"
        case .closeXcodeAndProceed:
            return "Close Xcode and proceed"
        case .cancel:
            return "Cancel operation"
        }
    }
}
