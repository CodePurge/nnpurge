//
//  XcodeRunningHandlerTests.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/6/25.
//

import Testing
import Foundation
import CodePurgeKit
import SwiftPickerKit
import CodePurgeTesting
import SwiftPickerTesting
@testable import nnpurge

struct XcodeRunningHandlerTests {
    @Test("Starting values empty")
    func emptyStartingValues() {
        let (_, service) = makeSUT()

        #expect(service.deletedItems.isEmpty)
        #expect(!service.forceWasUsed)
    }
}


// MARK: - Proceed Anyway Tests
extension XcodeRunningHandlerTests {
    @Test("Forces deletion when user selects proceed anyway")
    func forcesDeletionWhenUserSelectsProceedAnyway() throws {
        let items = ["Item1", "Item2", "Item3"]
        let proceedAnywayIndex = 0
        let (sut, service) = makeSUT(
            selectionResult: .init(singleType: .ordered([.index(proceedAnywayIndex)]))
        )

        try sut.handle(
            itemsToDelete: items,
            deleteOperation: service.deleteItems,
            xcodeFailedToCloseError: TestError.xcodeFailedToClose
        )

        #expect(service.deletedItems.count == items.count)
        #expect(service.forceWasUsed)
    }

    @Test("Passes all items to delete operation when proceeding anyway")
    func passesAllItemsToDeleteOperationWhenProceedingAnyway() throws {
        let item1 = "Item1"
        let item2 = "Item2"
        let items = [item1, item2]
        let proceedAnywayIndex = 0
        let (sut, service) = makeSUT(
            selectionResult: .init(singleType: .ordered([.index(proceedAnywayIndex)]))
        )

        try sut.handle(
            itemsToDelete: items,
            deleteOperation: service.deleteItems,
            xcodeFailedToCloseError: TestError.xcodeFailedToClose
        )

        #expect(service.deletedItems.contains(item1))
        #expect(service.deletedItems.contains(item2))
    }
}


// MARK: - Wait Until User Closes Xcode Tests
extension XcodeRunningHandlerTests {
    @Test("Deletes items when user confirms Xcode is closed")
    func deletesItemsWhenUserConfirmsXcodeIsClosed() throws {
        let items = ["Item1", "Item2"]
        let waitUntilClosedIndex = 1
        let (sut, service) = makeSUT(
            permissionResult: .init(defaultValue: true, type: .ordered([true])),
            selectionResult: .init(singleType: .ordered([.index(waitUntilClosedIndex)]))
        )

        try sut.handle(
            itemsToDelete: items,
            deleteOperation: service.deleteItems,
            xcodeFailedToCloseError: TestError.xcodeFailedToClose
        )

        #expect(service.deletedItems.count == items.count)
        #expect(!service.forceWasUsed)
    }

    @Test("Uses non-force deletion when user confirms Xcode is closed")
    func usesNonForceDeletionWhenUserConfirmsXcodeIsClosed() throws {
        let items = ["Item1"]
        let waitUntilClosedIndex = 1
        let (sut, service) = makeSUT(
            permissionResult: .init(defaultValue: true, type: .ordered([true])),
            selectionResult: .init(singleType: .ordered([.index(waitUntilClosedIndex)]))
        )

        try sut.handle(
            itemsToDelete: items,
            deleteOperation: service.deleteItems,
            xcodeFailedToCloseError: TestError.xcodeFailedToClose
        )

        #expect(!service.forceWasUsed)
    }

    @Test("Throws error when user denies Xcode closure confirmation")
    func throwsErrorWhenUserDeniesXcodeClosureConfirmation() throws {
        let items = ["Item1"]
        let waitUntilClosedIndex = 1
        let (sut, service) = makeSUT(
            permissionResult: .init(defaultValue: false, type: .ordered([false])),
            selectionResult: .init(singleType: .ordered([.index(waitUntilClosedIndex)]))
        )

        #expect(throws: (any Error).self) {
            try sut.handle(
                itemsToDelete: items,
                deleteOperation: service.deleteItems,
                xcodeFailedToCloseError: TestError.xcodeFailedToClose
            )
        }
    }

    @Test("Does not delete items when user denies Xcode closure confirmation")
    func doesNotDeleteItemsWhenUserDeniesXcodeClosureConfirmation() throws {
        let items = ["Item1", "Item2"]
        let waitUntilClosedIndex = 1
        let (sut, service) = makeSUT(
            permissionResult: .init(defaultValue: false, type: .ordered([false])),
            selectionResult: .init(singleType: .ordered([.index(waitUntilClosedIndex)]))
        )

        try? sut.handle(
            itemsToDelete: items,
            deleteOperation: service.deleteItems,
            xcodeFailedToCloseError: TestError.xcodeFailedToClose
        )

        #expect(service.deletedItems.isEmpty)
    }

    @Test("Asks for confirmation before attempting deletion")
    func asksForConfirmationBeforeAttemptingDeletion() throws {
        let items = ["Item1"]
        let waitUntilClosedIndex = 1
        let expectedPrompt = "Have you closed Xcode?"
        let (sut, service) = makeSUT(
            permissionResult: .init(
                defaultValue: true,
                type: .dictionary([expectedPrompt: true])
            ),
            selectionResult: .init(singleType: .ordered([.index(waitUntilClosedIndex)]))
        )

        try sut.handle(
            itemsToDelete: items,
            deleteOperation: service.deleteItems,
            xcodeFailedToCloseError: TestError.xcodeFailedToClose
        )

        #expect(service.deletedItems.count == items.count)
    }
}


// MARK: - Cancel Tests
extension XcodeRunningHandlerTests {
    @Test("Does not delete items when user cancels operation")
    func doesNotDeleteItemsWhenUserCancelsOperation() throws {
        let items = ["Item1", "Item2", "Item3"]
        let cancelIndex = 2
        let (sut, service) = makeSUT(
            selectionResult: .init(singleType: .ordered([.index(cancelIndex)]))
        )

        try sut.handle(
            itemsToDelete: items,
            deleteOperation: service.deleteItems,
            xcodeFailedToCloseError: TestError.xcodeFailedToClose
        )

        #expect(service.deletedItems.isEmpty)
    }
}


// MARK: - User Prompt Tests
extension XcodeRunningHandlerTests {
    @Test("Shows correct prompt to user when Xcode is running")
    func showsCorrectPromptToUserWhenXcodeIsRunning() throws {
        let expectedPrompt = "Xcode is currently running. What would you like to do?"
        let cancelIndex = 2
        let (sut, service) = makeSUT(
            selectionResult: .init(
                singleType: .dictionary([expectedPrompt: .index(cancelIndex)])
            )
        )

        try sut.handle(
            itemsToDelete: ["Item1"],
            deleteOperation: service.deleteItems,
            xcodeFailedToCloseError: TestError.xcodeFailedToClose
        )
    }

    @Test("Provides three options to user")
    func providesThreeOptionsToUser() throws {
        let cancelIndex = 2
        let (sut, service) = makeSUT(
            selectionResult: .init(singleType: .ordered([.index(cancelIndex)]))
        )

        try sut.handle(
            itemsToDelete: ["Item1"],
            deleteOperation: service.deleteItems,
            xcodeFailedToCloseError: TestError.xcodeFailedToClose
        )
    }
}


// MARK: - Generic Type Tests
extension XcodeRunningHandlerTests {
    @Test("Works with different item types")
    func worksWithDifferentItemTypes() throws {
        let items = [
            CustomItem(id: 1, name: "First"),
            CustomItem(id: 2, name: "Second")
        ]
        let proceedAnywayIndex = 0
        let (sut, _) = makeSUT(
            selectionResult: .init(singleType: .ordered([.index(proceedAnywayIndex)]))
        )
        let customService = MockCustomItemService()

        try sut.handle(
            itemsToDelete: items,
            deleteOperation: customService.deleteItems,
            xcodeFailedToCloseError: TestError.xcodeFailedToClose
        )

        #expect(customService.deletedItems.count == items.count)
        #expect(customService.deletedItems[0].name == items[0].name)
        #expect(customService.deletedItems[1].name == items[1].name)
    }
}


// MARK: - SUT
private extension XcodeRunningHandlerTests {
    func makeSUT(
        permissionResult: MockPermissionResult = .init(defaultValue: true, type: .ordered([])),
        selectionResult: MockSelectionResult = .init()
    ) -> (sut: XcodeRunningHandler, service: MockXcodeService) {
        let picker = MockSwiftPicker(
            permissionResult: permissionResult,
            selectionResult: selectionResult
        )
        let progressHandler = MockPurgeProgressHandler()
        let service = MockXcodeService()
        let sut = XcodeRunningHandler(picker: picker, progressHandler: progressHandler)

        return (sut, service)
    }
}


// MARK: - Test Helpers
private enum TestError: Error, Equatable {
    case xcodeFailedToClose
}

private struct CustomItem {
    let id: Int
    let name: String
}


// MARK: - Mock Service
private final class MockXcodeService: @unchecked Sendable {
    private(set) var deletedItems: [String] = []
    private(set) var forceWasUsed = false

    func deleteItems(_ items: [String], force: Bool, progressHandler: (any PurgeProgressHandler)?) throws {
        deletedItems = items
        forceWasUsed = force
    }
}

private final class MockCustomItemService: @unchecked Sendable {
    private(set) var deletedItems: [CustomItem] = []

    func deleteItems(_ items: [CustomItem], force: Bool, progressHandler: (any PurgeProgressHandler)?) throws {
        deletedItems = items
    }
}
