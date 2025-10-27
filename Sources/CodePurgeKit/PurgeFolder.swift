//
//  PurgeFolder.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 10/26/25.
//

import SwiftPicker

public struct PurgeFolder {
    public let name: String
    public let path: String
    public let size: Int

    public init(name: String, path: String, size: Int) {
        self.name = name
        self.path = path
        self.size = size
    }
}


// MARK: - DisplayablePickerItem
extension PurgeFolder: DisplayablePickerItem {
    public var displayName: String {
        return name
    }
}
