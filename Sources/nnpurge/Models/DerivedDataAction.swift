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
