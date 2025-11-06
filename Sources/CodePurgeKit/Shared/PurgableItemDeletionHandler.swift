//
//  PurgableItemDeletionHandler.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 11/6/25.
//

import Foundation

struct PurgableItemDeletionHandler {
    private let deleter: any PurgableItemDeleter
    private let xcodeChecker: any XcodeStatusChecker
    
    init(deleter: any PurgableItemDeleter, xcodeChecker: any XcodeStatusChecker) {
        self.deleter = deleter
        self.xcodeChecker = xcodeChecker
    }
}


extension PurgableItemDeletionHandler {
    func deleteItems<T: PurgableItem>(
        _ items: [T],
        force: Bool,
        progressHandler: (any PurgeProgressHandler)?,
        completionMessage: String,
        xcodeRunningError: Error
    ) throws {
        guard !items.isEmpty else {
            throw PurgableItemError.noItemsToDelete
        }

        if !force {
            guard !xcodeChecker.isXcodeRunning() else {
                throw xcodeRunningError
            }
        }

        let total = items.count

        for (index, item) in items.enumerated() {
            try deleter.deleteItem(at: item.url)
            progressHandler?.updateProgress(current: index + 1, total: total, message: "Moving \(item.name) to trash...")
        }

        progressHandler?.complete(message: completionMessage)
    }
}


// MARK: - Dependencies
public protocol PurgableItemDeleter {
    func deleteItem(at url: URL) throws
}

public protocol PurgableItem {
    var name: String { get }
    var url: URL { get }
}

public enum PurgableItemError: Error, Equatable {
    case noItemsToDelete
}
