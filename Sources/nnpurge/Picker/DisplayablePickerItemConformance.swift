//
//  DisplayablePickerItemConformance.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 12/14/25.
//

import Files
import CodePurgeKit
import SwiftPickerKit

extension ArchiveFolder: DisplayablePickerItem {
    public var displayName: String {
        return name // TODO: -
    }
}

struct DisplayableDeleteOption: DisplayablePickerItem {
    let option: DeleteOption
    let displayName: String

    init(_ option: DeleteOption, displayName: String) {
        self.option = option
        self.displayName = displayName
    }
}

extension Folder: @retroactive DisplayablePickerItem {
    public var displayName: String {
        return name
    }
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

extension ArchiveOption: DisplayablePickerItem {
    var displayName: String {
        switch self {
        case .deleteStale:
            return "Delete stale archives (30+ days old)"
        case .selectFolders:
            return "Select specific archives to delete"
        }
    }
}

extension DerivedDataFolder: DisplayablePickerItem {
    public var displayName: String {
        return name
    }
}

extension DerivedDataDeleteOption: DisplayablePickerItem {
    var displayName: String {
        switch self {
        case .deleteAll:
            return "Delete all derived data folders"
        case .selectFolders:
            return "Select specific folders to delete"
        }
    }
}

extension PackageCacheFolder: DisplayablePickerItem {
    public var displayName: String {
        return name // TODO: - may need to expand or format somehow
    }
}

extension PackageCacheDeleteOption: DisplayablePickerItem {
    var displayName: String {
        switch self {
        case .deleteAll:
            return "Delete all package repositories"
        case .deleteStale:
            return "Delete stale packages (30+ days old)"
        case .selectFolders:
            return "Select specific packages to delete"
        }
    }
}
