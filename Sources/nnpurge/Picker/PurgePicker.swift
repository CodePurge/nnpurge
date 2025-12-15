//
//  PurgePicker.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 12/14/25.
//

import SwiftPickerKit

protocol PurgePicker {
    func requiredPermission(prompt: String) throws
    func requiredSingleSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item], layout: PickerLayout<Item>, newScreen: Bool, showSelectedItemText: Bool) throws -> Item
    func multiSelection<Item: DisplayablePickerItem>(prompt: String, items: [Item], layout: PickerLayout<Item>, newScreen: Bool, showSelectedItemText: Bool) -> [Item]
}


extension PurgePicker {
    func requiredPermission(_ prompt: String) throws {
        try requiredPermission(prompt: prompt)
    }
    
    func requiredSingleSelection<Item: DisplayablePickerItem>(_ prompt: String, items: [Item], layout: PickerLayout<Item> = .singleColumn, newScreen: Bool = true, showSelectedItemText: Bool = true) throws -> Item {
        return try requiredSingleSelection(prompt: prompt, items: items, layout: layout, newScreen: newScreen, showSelectedItemText: showSelectedItemText)
    }
    
    func multiSelection<Item: DisplayablePickerItem>(_ prompt: String, items: [Item], layout: PickerLayout<Item> = .singleColumn, newScreen: Bool = true, showSelectedItemText: Bool = true) -> [Item] {
        return multiSelection(prompt: prompt, items: items, layout: layout, newScreen: newScreen, showSelectedItemText: showSelectedItemText)
    }
}
