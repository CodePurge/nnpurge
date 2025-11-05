//
//  PurgeFolder+DisplayablePickerItem.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import SwiftPicker
import CodePurgeKit

extension OldPurgeFolder: DisplayablePickerItem {
    public var displayName: String {
        return name
    }
}
