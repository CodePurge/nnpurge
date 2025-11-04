//
//  ArchiveFolder+DisplayablePickerItem.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/4/25.
//

import SwiftPicker
import CodePurgeKit

extension ArchiveFolder: DisplayablePickerItem {
    public var displayName: String {
        return name // TODO: -
    }
}
