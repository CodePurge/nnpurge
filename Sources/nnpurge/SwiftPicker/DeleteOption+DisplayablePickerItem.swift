//
//  DeleteOption+DisplayablePickerItem.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import SwiftPicker

struct DisplayableDeleteOption: DisplayablePickerItem {
    let option: DeleteOption
    let displayName: String

    init(_ option: DeleteOption, displayName: String) {
        self.option = option
        self.displayName = displayName
    }
}
