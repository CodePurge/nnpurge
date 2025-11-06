//
//  XcodeRunningHandler.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/6/25.
//

import Foundation
import SwiftPicker
import CodePurgeKit

struct XcodeRunningHandler {
    private let picker: any CommandLinePicker
    private let progressHandler: any PurgeProgressHandler

    init(picker: any CommandLinePicker, progressHandler: any PurgeProgressHandler) {
        self.picker = picker
        self.progressHandler = progressHandler
    }
}


// MARK: - Handle
extension XcodeRunningHandler {
    func handle<Item>(
        itemsToDelete: [Item],
        deleteOperation: ([Item], Bool, (any PurgeProgressHandler)?) throws -> Void,
        xcodeFailedToCloseError: Error
    ) throws {
        let option = try picker.requiredSingleSelection("Xcode is currently running. What would you like to do?", items: XcodeRunningOption.allCases)

        switch option {
        case .proceedAnyway:
            try deleteOperation(itemsToDelete, true, progressHandler)
        case .waitUntilUserClosesXcode:
            print("\n⚠️  Please close Xcode before proceeding.")
            try picker.requiredPermission("Have you closed Xcode?")
            try deleteOperation(itemsToDelete, false, progressHandler)
        case .cancel:
            print("Operation cancelled.")
        }
    }
}
