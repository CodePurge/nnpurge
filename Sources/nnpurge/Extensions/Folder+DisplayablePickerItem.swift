//
//  Folder+DisplayablePickerItem.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import Files
import SwiftPicker

/// Makes ``Folder`` items presentable in selection lists.
extension Folder: @retroactive DisplayablePickerItem {
    /// Human-readable name used when displaying the folder in a picker.
    public var displayName: String {
        name
    }
}
