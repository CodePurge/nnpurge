//
//  XcodeRunningHandlerTests.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/6/25.
//

import Testing
import Foundation
import SwiftPicker
import CodePurgeKit
import CodePurgeTesting
import SwiftPickerTesting
@testable import nnpurge

struct XcodeRunningHandlerTests {
    @Test("Starting values empty")
    func emptyStartingValues() {
        let (_, service) = makeSUT()

        #expect(!service.didCloseXcode)
        #expect(service.deletedItems.isEmpty)
    }
}


// MARK: - Proceed Anyway Tests
extension XcodeRunningHandlerTests {
    @Test("Forces deletion when user selects proceed anyway")
    func forcesDeletionWhenUserSelectsProceedAnyway() throws {
        let items = ["Item1", "Item2", "Item3"]
        let proceedAnywayIndex = 0
        let (sut, service) = makeSUT(
            selectionResult: .init(singleSelectionType: .ordered([proceedAnywayIndex]))
        )

        try sut.handle(
            itemsToDelete: items,
            deleteOperation: service.deleteItems,
            closeXcodeOperation: service.closeXcode,
            xcodeFailedToCloseError: TestError.xcodeFailedToClose
        )

        #expect(service.deletedItems.count == items.count)
        #expect(service.forceWasUsed)
        #expect(!service.didCloseXcode)
    }

    @Test("Passes all items to delete operation when proceeding anyway")
    func passesAllItemsToDeleteOperationWhenProceedingAnyway() throws {
        let item1 = "Item1"
        let item2 = "Item2"
        let items = [item1, item2]
        let proceedAnywayIndex = 0
        let (sut, service) = makeSUT(
            selectionResult: .init(singleSelectionType: .ordered([proceedAnywayIndex]))
        )

        try sut.handle(
            itemsToDelete: items,
            deleteOperation: service.deleteItems,
            closeXcodeOperation: service.closeXcode,
            xcodeFailedToCloseError: TestError.xcodeFailedToClose
        )

        #expect(service.deletedItems.contains(item1))
        #expect(service.deletedItems.contains(item2))
    }
}


// MARK: - Close Xcode And Proceed Tests
extension XcodeRunningHandlerTests {
    @Test("Closes Xcode and deletes items when user selects close Xcode option")
    func closesXcodeAndDeletesItemsWhenUserSelectsCloseXcodeOption() throws {
        let items = ["Item1", "Item2"]
        let closeXcodeIndex = 1
        let (sut, service) = makeSUT(
            selectionResult: .init(singleSelectionType: .ordered([closeXcodeIndex])),
            closeXcodeSucceeds: true
        )

        try sut.handle(
            itemsToDelete: items,
            deleteOperation: service.deleteItems,
            closeXcodeOperation: service.closeXcode,
            xcodeFailedToCloseError: TestError.xcodeFailedToClose
        )

        #expect(service.didCloseXcode)
        #expect(service.deletedItems.count == items.count)
        #expect(!service.forceWasUsed)
    }

    @Test("Uses non-force deletion after successfully closing Xcode")
    func usesNonForceDeletionAfterSuccessfullyClosingXcode() throws {
        let items = ["Item1"]
        let closeXcodeIndex = 1
        let (sut, service) = makeSUT(
            selectionResult: .init(singleSelectionType: .ordered([closeXcodeIndex])),
            closeXcodeSucceeds: true
        )

        try sut.handle(
            itemsToDelete: items,
            deleteOperation: service.deleteItems,
            closeXcodeOperation: service.closeXcode,
            xcodeFailedToCloseError: TestError.xcodeFailedToClose
        )

        #expect(!service.forceWasUsed)
    }

    @Test("Throws error when Xcode fails to close")
    func throwsErrorWhenXcodeFailsToClose() throws {
        let items = ["Item1"]
        let closeXcodeIndex = 1
        let (sut, service) = makeSUT(
            selectionResult: .init(singleSelectionType: .ordered([closeXcodeIndex])),
            closeXcodeSucceeds: false
        )

        #expect(throws: TestError.xcodeFailedToClose) {
            try sut.handle(
                itemsToDelete: items,
                deleteOperation: service.deleteItems,
                closeXcodeOperation: service.closeXcode,
                xcodeFailedToCloseError: TestError.xcodeFailedToClose
            )
        }
    }

    @Test("Does not delete items when Xcode fails to close")
    func doesNotDeleteItemsWhenXcodeFailsToClose() throws {
        let items = ["Item1", "Item2"]
        let closeXcodeIndex = 1
        let (sut, service) = makeSUT(
            selectionResult: .init(singleSelectionType: .ordered([closeXcodeIndex])),
            closeXcodeSucceeds: false
        )

        try? sut.handle(
            itemsToDelete: items,
            deleteOperation: service.deleteItems,
            closeXcodeOperation: service.closeXcode,
            xcodeFailedToCloseError: TestError.xcodeFailedToClose
        )

        #expect(service.deletedItems.isEmpty)
    }

    @Test("Closes Xcode before attempting deletion")
    func closesXcodeBeforeAttemptingDeletion() throws {
        let items = ["Item1"]
        let closeXcodeIndex = 1
        let (sut, service) = makeSUT(
            selectionResult: .init(singleSelectionType: .ordered([closeXcodeIndex])),
            closeXcodeSucceeds: true
        )

        try sut.handle(
            itemsToDelete: items,
            deleteOperation: service.deleteItems,
            closeXcodeOperation: service.closeXcode,
            xcodeFailedToCloseError: TestError.xcodeFailedToClose
        )

        #expect(service.didCloseXcode)
        #expect(service.closeXcodeCalledBeforeDeletion)
    }
}


// MARK: - Cancel Tests
extension XcodeRunningHandlerTests {
    @Test("Does not delete items when user cancels operation")
    func doesNotDeleteItemsWhenUserCancelsOperation() throws {
        let items = ["Item1", "Item2", "Item3"]
        let cancelIndex = 2
        let (sut, service) = makeSUT(
            selectionResult: .init(singleSelectionType: .ordered([cancelIndex]))
        )

        try sut.handle(
            itemsToDelete: items,
            deleteOperation: service.deleteItems,
            closeXcodeOperation: service.closeXcode,
            xcodeFailedToCloseError: TestError.xcodeFailedToClose
        )

        #expect(service.deletedItems.isEmpty)
    }

    @Test("Does not close Xcode when user cancels operation")
    func doesNotCloseXcodeWhenUserCancelsOperation() throws {
        let items = ["Item1"]
        let cancelIndex = 2
        let (sut, service) = makeSUT(
            selectionResult: .init(singleSelectionType: .ordered([cancelIndex]))
        )

        try sut.handle(
            itemsToDelete: items,
            deleteOperation: service.deleteItems,
            closeXcodeOperation: service.closeXcode,
            xcodeFailedToCloseError: TestError.xcodeFailedToClose
        )

        #expect(!service.didCloseXcode)
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
                singleSelectionType: .dictionary([expectedPrompt: cancelIndex])
            )
        )

        try sut.handle(
            itemsToDelete: ["Item1"],
            deleteOperation: service.deleteItems,
            closeXcodeOperation: service.closeXcode,
            xcodeFailedToCloseError: TestError.xcodeFailedToClose
        )
    }

    @Test("Provides three options to user")
    func providesThreeOptionsToUser() throws {
        let cancelIndex = 2
        let (sut, service) = makeSUT(
            selectionResult: .init(singleSelectionType: .ordered([cancelIndex]))
        )

        try sut.handle(
            itemsToDelete: ["Item1"],
            deleteOperation: service.deleteItems,
            closeXcodeOperation: service.closeXcode,
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
            selectionResult: .init(singleSelectionType: .ordered([proceedAnywayIndex]))
        )
        let customService = MockCustomItemService()

        try sut.handle(
            itemsToDelete: items,
            deleteOperation: customService.deleteItems,
            closeXcodeOperation: customService.closeXcode,
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
        selectionResult: MockSelectionResult = .init(),
        closeXcodeSucceeds: Bool = true
    ) -> (sut: XcodeRunningHandler, service: MockXcodeService) {
        let picker = MockSwiftPicker(selectionResult: selectionResult)
        let progressHandler = MockPurgeProgressHandler()
        let service = MockXcodeService(closeXcodeSucceeds: closeXcodeSucceeds)
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
    private let closeXcodeSucceeds: Bool
    private var closeXcodeCallOrder = 0
    private var deleteItemsCallOrder = 0

    private(set) var didCloseXcode = false
    private(set) var deletedItems: [String] = []
    private(set) var forceWasUsed = false
    private(set) var closeXcodeCalledBeforeDeletion = false

    init(closeXcodeSucceeds: Bool) {
        self.closeXcodeSucceeds = closeXcodeSucceeds
    }

    func deleteItems(_ items: [String], force: Bool, progressHandler: (any PurgeProgressHandler)?) throws {
        deleteItemsCallOrder = closeXcodeCallOrder + 1
        deletedItems = items
        forceWasUsed = force
        closeXcodeCalledBeforeDeletion = closeXcodeCallOrder > 0 && closeXcodeCallOrder < deleteItemsCallOrder
    }

    func closeXcode(_ timeout: TimeInterval) throws {
        closeXcodeCallOrder = deleteItemsCallOrder + 1
        didCloseXcode = true

        if !closeXcodeSucceeds {
            throw TestError.xcodeFailedToClose
        }
    }
}

private final class MockCustomItemService: @unchecked Sendable {
    private(set) var deletedItems: [CustomItem] = []

    func deleteItems(_ items: [CustomItem], force: Bool, progressHandler: (any PurgeProgressHandler)?) throws {
        deletedItems = items
    }

    func closeXcode(_ timeout: TimeInterval) throws {
        // No-op for this test
    }
}
