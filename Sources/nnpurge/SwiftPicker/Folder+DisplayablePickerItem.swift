//
//  Folder+DisplayablePickerItem.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 6/17/25.
//

import Files
import SwiftPicker

extension Folder: @retroactive DisplayablePickerItem {
    public var displayName: String {
        return name
    }
}
