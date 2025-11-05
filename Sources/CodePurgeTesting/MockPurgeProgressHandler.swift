//
//  MockPurgeProgressHandler.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/4/25.
//

import Foundation
import CodePurgeKit

public final class MockPurgeProgressHandler: @unchecked Sendable, PurgeProgressHandler {
    public private(set) var didComplete = false
    public private(set) var completedMessage: String?
    public private(set) var progressUpdates: [ProgressData] = []

    public init() {}

    public func complete(message: String?) {
        didComplete = true
        completedMessage = message
    }

    public func updateProgress(current: Int, total: Int, message: String) {
        progressUpdates.append(.init(index: current, message: message))
    }
}


// MARK: - Dependencies
extension MockPurgeProgressHandler {
    public struct ProgressData {
        public let index: Int
        public let message: String
    }
}
