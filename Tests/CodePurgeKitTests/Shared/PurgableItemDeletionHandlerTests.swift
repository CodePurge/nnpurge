//
//  PurgableItemDeletionHandlerTests.swift
//  CodePurgeKit
//
//  Created by Nikolai Nobadi on 11/6/25.
//

import Testing
import Foundation
import CodePurgeTesting
@testable import CodePurgeKit

struct PurgableItemDeletionHandlerTests {
    @Test("Starting values empty")
    func emptyStartingValues() {
        let (_, deleter, _) = makeSUT()

        #expect(deleter.deletedURLs.isEmpty)
    }
}


// MARK: - Delete Items Tests
extension PurgableItemDeletionHandlerTests {
    @Test("Deletes all items when Xcode is not running")
    func deletesAllItemsWhenXcodeIsNotRunning() throws {
        let item1 = makeTestItem(name: "Item1")
        let item2 = makeTestItem(name: "Item2")
        let item3 = makeTestItem(name: "Item3")
        let items = [item1, item2, item3]
        let (sut, deleter, _) = makeSUT(isXcodeRunning: false)

        try sut.deleteItems(items, force: false, progressHandler: nil, completionMessage: "Done", xcodeRunningError: TestError.testError)

        #expect(deleter.deletedURLs.count == 3)
        #expect(deleter.deletedURLs.contains(item1.url))
        #expect(deleter.deletedURLs.contains(item2.url))
        #expect(deleter.deletedURLs.contains(item3.url))
    }

    @Test("Deletes items in correct order")
    func deletesItemsInCorrectOrder() throws {
        let item1 = makeTestItem(name: "First")
        let item2 = makeTestItem(name: "Second")
        let item3 = makeTestItem(name: "Third")
        let items = [item1, item2, item3]
        let (sut, deleter, _) = makeSUT()

        try sut.deleteItems(items, force: false, progressHandler: nil, completionMessage: "Done", xcodeRunningError: TestError.testError)

        #expect(deleter.deletedURLs.count == 3)
        guard deleter.deletedURLs.count >= 3 else { return }
        #expect(deleter.deletedURLs[0] == item1.url)
        #expect(deleter.deletedURLs[1] == item2.url)
        #expect(deleter.deletedURLs[2] == item3.url)
    }

    @Test("Completes successfully when given empty array")
    func completesSuccessfullyWhenGivenEmptyArray() throws {
        let (sut, deleter, _) = makeSUT()
        let emptyItems: [TestPurgableItem] = []

        try sut.deleteItems(emptyItems, force: false, progressHandler: nil, completionMessage: "Done", xcodeRunningError: TestError.testError)

        #expect(deleter.deletedURLs.isEmpty)
    }

    @Test("Deletes single item successfully")
    func deletesSingleItemSuccessfully() throws {
        let item = makeTestItem(name: "SingleItem")
        let (sut, deleter, _) = makeSUT()

        try sut.deleteItems([item], force: false, progressHandler: nil, completionMessage: "Done", xcodeRunningError: TestError.testError)

        #expect(deleter.deletedURLs.count == 1)
        guard deleter.deletedURLs.count >= 1 else { return }
        #expect(deleter.deletedURLs[0] == item.url)
    }
}


// MARK: - Xcode Running Check Tests
extension PurgableItemDeletionHandlerTests {
    @Test("Throws xcodeRunningError when Xcode is running and force is false")
    func throwsXcodeRunningErrorWhenXcodeIsRunningAndForceIsFalse() throws {
        let item = makeTestItem(name: "TestItem")
        let (sut, deleter, _) = makeSUT(isXcodeRunning: true)

        #expect(throws: TestError.testError) {
            try sut.deleteItems([item], force: false, progressHandler: nil, completionMessage: "Done", xcodeRunningError: TestError.testError)
        }

        #expect(deleter.deletedURLs.isEmpty)
    }

    @Test("Bypasses Xcode check when force is true")
    func bypassesXcodeCheckWhenForceIsTrue() throws {
        let item1 = makeTestItem(name: "Item1")
        let item2 = makeTestItem(name: "Item2")
        let items = [item1, item2]
        let (sut, deleter, _) = makeSUT(isXcodeRunning: true)

        try sut.deleteItems(items, force: true, progressHandler: nil, completionMessage: "Done", xcodeRunningError: TestError.testError)

        #expect(deleter.deletedURLs.count == 2)
        #expect(deleter.deletedURLs.contains(item1.url))
        #expect(deleter.deletedURLs.contains(item2.url))
    }

    @Test("Checks Xcode status before attempting any deletions")
    func checksXcodeStatusBeforeAttemptingAnyDeletions() throws {
        let item1 = makeTestItem(name: "Item1")
        let item2 = makeTestItem(name: "Item2")
        let item3 = makeTestItem(name: "Item3")
        let items = [item1, item2, item3]
        let (sut, deleter, _) = makeSUT(isXcodeRunning: true)

        #expect(throws: TestError.testError) {
            try sut.deleteItems(items, force: false, progressHandler: nil, completionMessage: "Done", xcodeRunningError: TestError.testError)
        }

        #expect(deleter.deletedURLs.isEmpty)
    }
}


// MARK: - Progress Handler Tests
extension PurgableItemDeletionHandlerTests {
    @Test("Calls progress handler for each item with correct index and message")
    func callsProgressHandlerForEachItemWithCorrectIndexAndMessage() throws {
        let item1 = makeTestItem(name: "Alpha")
        let item2 = makeTestItem(name: "Beta")
        let item3 = makeTestItem(name: "Gamma")
        let items = [item1, item2, item3]
        let progressHandler = MockPurgeProgressHandler()
        let (sut, _, _) = makeSUT()

        try sut.deleteItems(items, force: false, progressHandler: progressHandler, completionMessage: "All done", xcodeRunningError: TestError.testError)

        #expect(progressHandler.progressUpdates.count == 3)
        guard progressHandler.progressUpdates.count >= 3 else { return }
        #expect(progressHandler.progressUpdates[0].index == 1)
        #expect(progressHandler.progressUpdates[0].message.contains(item1.name))
        #expect(progressHandler.progressUpdates[1].index == 2)
        #expect(progressHandler.progressUpdates[1].message.contains(item2.name))
        #expect(progressHandler.progressUpdates[2].index == 3)
        #expect(progressHandler.progressUpdates[2].message.contains(item3.name))
    }

    @Test("Calls complete on progress handler after all deletions")
    func callsCompleteOnProgressHandlerAfterAllDeletions() throws {
        let items = [makeTestItem(name: "Item1"), makeTestItem(name: "Item2")]
        let progressHandler = MockPurgeProgressHandler()
        let completionMessage = "✅ All items deleted successfully"
        let (sut, _, _) = makeSUT()

        try sut.deleteItems(items, force: false, progressHandler: progressHandler, completionMessage: completionMessage, xcodeRunningError: TestError.testError)

        #expect(progressHandler.didComplete)
        #expect(progressHandler.completedMessage == completionMessage)
    }

    @Test("Calls complete even when no items to delete")
    func callsCompleteEvenWhenNoItemsToDelete() throws {
        let progressHandler = MockPurgeProgressHandler()
        let completionMessage = "Done"
        let (sut, _, _) = makeSUT()
        let emptyItems: [TestPurgableItem] = []

        try sut.deleteItems(emptyItems, force: false, progressHandler: progressHandler, completionMessage: completionMessage, xcodeRunningError: TestError.testError)

        #expect(progressHandler.progressUpdates.isEmpty)
        #expect(progressHandler.didComplete)
        #expect(progressHandler.completedMessage == completionMessage)
    }

    @Test("Works correctly when progress handler is nil")
    func worksCorrectlyWhenProgressHandlerIsNil() throws {
        let item = makeTestItem(name: "TestItem")
        let (sut, deleter, _) = makeSUT()

        try sut.deleteItems([item], force: false, progressHandler: nil, completionMessage: "Done", xcodeRunningError: TestError.testError)

        #expect(deleter.deletedURLs.count == 1)
        #expect(deleter.deletedURLs[0] == item.url)
    }

    @Test("Does not call progress handler when Xcode running check fails")
    func doesNotCallProgressHandlerWhenXcodeRunningCheckFails() throws {
        let item = makeTestItem(name: "TestItem")
        let progressHandler = MockPurgeProgressHandler()
        let (sut, _, _) = makeSUT(isXcodeRunning: true)

        #expect(throws: TestError.testError) {
            try sut.deleteItems([item], force: false, progressHandler: progressHandler, completionMessage: "Done", xcodeRunningError: TestError.testError)
        }

        #expect(progressHandler.progressUpdates.isEmpty)
        #expect(!progressHandler.didComplete)
    }
}


// MARK: - Error Propagation Tests
extension PurgableItemDeletionHandlerTests {
    @Test("Propagates deletion error from deleter")
    func propagatesDeletionErrorFromDeleter() throws {
        let item = makeTestItem(name: "ErrorItem")
        let (sut, _, _) = makeSUT(throwError: true)

        #expect(throws: NSError.self) {
            try sut.deleteItems([item], force: false, progressHandler: nil, completionMessage: "Done", xcodeRunningError: TestError.testError)
        }
    }

    @Test("Stops deletion on first error and does not continue")
    func stopsDeletionOnFirstErrorAndDoesNotContinue() throws {
        let item1 = makeTestItem(name: "Item1")
        let item2 = makeTestItem(name: "Item2")
        let item3 = makeTestItem(name: "Item3")
        let items = [item1, item2, item3]
        let (sut, deleter, _) = makeSUT(throwError: true)

        #expect(throws: NSError.self) {
            try sut.deleteItems(items, force: false, progressHandler: nil, completionMessage: "Done", xcodeRunningError: TestError.testError)
        }

        #expect(deleter.deletedURLs.isEmpty)
    }

    @Test("Does not call complete when deletion fails")
    func doesNotCallCompleteWhenDeletionFails() throws {
        let item = makeTestItem(name: "ErrorItem")
        let progressHandler = MockPurgeProgressHandler()
        let (sut, _, _) = makeSUT(throwError: true)

        #expect(throws: NSError.self) {
            try sut.deleteItems([item], force: false, progressHandler: progressHandler, completionMessage: "Done", xcodeRunningError: TestError.testError)
        }

        #expect(!progressHandler.didComplete)
    }
}


// MARK: - SUT
private extension PurgableItemDeletionHandlerTests {
    func makeSUT(
        throwError: Bool = false,
        isXcodeRunning: Bool = false
    ) -> (sut: PurgableItemDeletionHandler, deleter: MockDeleter, xcodeChecker: MockXcodeChecker) {
        let deleter = MockDeleter(throwError: throwError)
        let xcodeChecker = MockXcodeChecker(xcodeRunningStatus: isXcodeRunning)
        let sut = PurgableItemDeletionHandler(deleter: deleter, xcodeChecker: xcodeChecker)

        return (sut, deleter, xcodeChecker)
    }

    func makeTestItem(name: String) -> TestPurgableItem {
        let url = URL(fileURLWithPath: "/test/path/\(name)")
        return TestPurgableItem(name: name, url: url)
    }
}


// MARK: - Test Helpers
private struct TestPurgableItem: PurgableItem {
    let name: String
    let url: URL
}

private enum TestError: Error, Equatable {
    case testError
}


// MARK: - Mocks
private final class MockDeleter: PurgableItemDeleter, @unchecked Sendable {
    private let throwError: Bool

    private(set) var deletedURLs: [URL] = []

    init(throwError: Bool = false) {
        self.throwError = throwError
    }

    func deleteItem(at url: URL) throws {
        if throwError {
            throw NSError(domain: "MockDeleter", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        }
        deletedURLs.append(url)
    }
}

private struct MockXcodeChecker: XcodeStatusChecker {
    let xcodeRunningStatus: Bool

    func isXcodeRunning() -> Bool {
        return xcodeRunningStatus
    }
}
