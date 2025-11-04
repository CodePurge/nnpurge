//
//  PackageCacheControllerTests.swift
//  nnpurge
//
//  Created by Nikolai Nobadi on 11/3/25.
//

import Testing
import Foundation
import SwiftPicker
import CodePurgeKit
import CodePurgeTesting
import SwiftPickerTesting
@testable import nnpurge

struct PackageCacheControllerTests {
    @Test("Starting values empty")
    func emptyStartingValues() {
        let (_, service, progressHandler) = makeSUT()

        #expect(!service.didDeleteAllPackages)
        #expect(service.deletedFolders.isEmpty)
        #expect(progressHandler.deletedFolders.isEmpty)
    }
}


// MARK: - Delete All Flag Tests
extension PackageCacheControllerTests {
    @Test("Deletes all packages when flag true and permission granted")
    func deletesAllPackagesWhenFlagTrueAndPermissionGranted() throws {
        let (sut, service, _) = makeSUT(
            permissionResult: .init(type: .ordered([true]))
        )

        try sut.deletePackageCache(deleteAll: true)

        #expect(service.didDeleteAllPackages)
    }

    @Test("Throws error when delete all flag true but permission denied")
    func throwsErrorWhenDeleteAllFlagTrueButPermissionDenied() throws {
        let (sut, _, _) = makeSUT(
            permissionResult: .init(type: .ordered([false]))
        )

        #expect(throws: SwiftPickerError.selectionCancelled) {
            try sut.deletePackageCache(deleteAll: true)
        }
    }

    @Test("Requests permission with correct prompt when deleting all")
    func requestsPermissionWithCorrectPromptWhenDeletingAll() throws {
        let expectedPrompt = "Are you sure you want to delete all cached package repositories?"
        let (sut, _, _) = makeSUT(
            permissionResult: .init(
                type: .dictionary([expectedPrompt: true])
            )
        )

        try sut.deletePackageCache(deleteAll: true)
    }
}


// MARK: - Select Option Flow Tests
extension PackageCacheControllerTests {
    @Test("Shows option selection when delete all flag false")
    func showsOptionSelectionWhenDeleteAllFlagFalse() throws {
        let (sut, _, _) = makeSUT(
            permissionResult: .init(type: .ordered([true])),
            selectionResult: .init(
                singleSelectionType: .ordered([0])
            )
        )

        try sut.deletePackageCache(deleteAll: false)
    }

    @Test("Throws error when user cancels option selection")
    func throwsErrorWhenUserCancelsOptionSelection() throws {
        let (sut, _, _) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([nil])
            )
        )

        #expect(throws: SwiftPickerError.selectionCancelled) {
            try sut.deletePackageCache(deleteAll: false)
        }
    }

    @Test("Deletes all when user selects delete all option")
    func deletesAllWhenUserSelectsDeleteAllOption() throws {
        let deleteAllIndex = 0
        let (sut, service, _) = makeSUT(
            permissionResult: .init(type: .ordered([true])),
            selectionResult: .init(
                singleSelectionType: .ordered([deleteAllIndex])
            )
        )

        try sut.deletePackageCache(deleteAll: false)

        #expect(service.didDeleteAllPackages)
    }

    @Test("Shows package selection when user selects select folders option")
    func showsPackageSelectionWhenUserSelectsSelectFoldersOption() throws {
        let selectFoldersIndex = 2
        let packages = [
            makePurgeFolder(name: "Package1"),
            makePurgeFolder(name: "Package2")
        ]
        let (sut, service, _) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([selectFoldersIndex]),
                multiSelectionType: .ordered([[0]])
            ),
            foldersToLoad: packages
        )

        try sut.deletePackageCache(deleteAll: false)

        #expect(service.deletedFolders.count == 1)
        #expect(service.deletedFolders.first?.name == packages[0].name)
    }
}


// MARK: - Select Packages Flow Tests
extension PackageCacheControllerTests {
    @Test("Deletes selected packages when user makes selection")
    func deletesSelectedPackagesWhenUserMakesSelection() throws {
        let package1 = makePurgeFolder(name: "Package1")
        let package2 = makePurgeFolder(name: "Package2")
        let package3 = makePurgeFolder(name: "Package3")
        let packages = [package1, package2, package3]
        let selectedIndices = [0, 2]
        let (sut, service, _) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([2]),
                multiSelectionType: .ordered([selectedIndices])
            ),
            foldersToLoad: packages
        )

        try sut.deletePackageCache(deleteAll: false)

        #expect(service.deletedFolders.count == 2)
        #expect(service.deletedFolders.contains(where: { $0.name == package1.name }))
        #expect(service.deletedFolders.contains(where: { $0.name == package3.name }))
    }

    @Test("Deletes no packages when user selects none")
    func deletesNoPackagesWhenUserSelectsNone() throws {
        let packages = [
            makePurgeFolder(name: "Package1"),
            makePurgeFolder(name: "Package2")
        ]
        let (sut, service, _) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([2]),
                multiSelectionType: .ordered([[]])
            ),
            foldersToLoad: packages
        )

        try sut.deletePackageCache(deleteAll: false)

        #expect(service.deletedFolders.isEmpty)
    }

    @Test("Shows multi selection with correct prompt and packages")
    func showsMultiSelectionWithCorrectPromptAndPackages() throws {
        let expectedPrompt = "Select the package repositories to delete."
        let packages = [
            makePurgeFolder(name: "Package1"),
            makePurgeFolder(name: "Package2")
        ]
        let (sut, _, _) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([1]),
                multiSelectionType: .dictionary([expectedPrompt: [0]])
            ),
            foldersToLoad: packages
        )

        try sut.deletePackageCache(deleteAll: false)
    }
}


// MARK: - Error Handling Tests
extension PackageCacheControllerTests {
    @Test("Propagates delete all error from service")
    func propagatesDeleteAllErrorFromService() throws {
        let (sut, _, _) = makeSUT(
            permissionResult: .init(type: .ordered([true])),
            throwError: true
        )

        #expect(throws: NSError.self) {
            try sut.deletePackageCache(deleteAll: true)
        }
    }

    @Test("Propagates delete folders error from service")
    func propagatesDeleteFoldersErrorFromService() throws {
        let packages = [makePurgeFolder(name: "Package1")]
        let (sut, _, _) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([1]),
                multiSelectionType: .ordered([[0]])
            ),
            throwError: true,
            foldersToLoad: packages
        )

        #expect(throws: NSError.self) {
            try sut.deletePackageCache(deleteAll: false)
        }
    }
}


// MARK: - Open Folder Tests
extension PackageCacheControllerTests {
    @Test("Opens package cache folder at correct path")
    func opensPackageCacheFolderAtCorrectPath() throws {
        let (sut, service, _) = makeSUT()

        try sut.openPackageCacheFolder()

        let openedURL = try #require(service.openedFolderURL)
        #expect(openedURL.path.contains("org.swift.swiftpm/repositories"))
    }

    @Test("Propagates open folder error from service")
    func propagatesOpenFolderErrorFromService() throws {
        let (sut, _, _) = makeSUT(throwError: true)

        #expect(throws: NSError.self) {
            try sut.openPackageCacheFolder()
        }
    }
}


// MARK: - Progress Handler Tests
extension PackageCacheControllerTests {
    @Test("Reports progress for each package when deleting all")
    func reportsProgressForEachPackageWhenDeletingAll() throws {
        let package1 = makePurgeFolder(name: "Package1")
        let package2 = makePurgeFolder(name: "Package2")
        let package3 = makePurgeFolder(name: "Package3")
        let packages = [package1, package2, package3]
        let (sut, _, progressHandler) = makeSUT(
            permissionResult: .init(type: .ordered([true])),
            foldersToLoad: packages
        )

        try sut.deletePackageCache(deleteAll: true)

        #expect(progressHandler.deletedFolders.count == packages.count)
        guard progressHandler.deletedFolders.count >= 3 else { return }
        #expect(progressHandler.deletedFolders[0].name == package1.name)
        #expect(progressHandler.deletedFolders[1].name == package2.name)
        #expect(progressHandler.deletedFolders[2].name == package3.name)
    }

    @Test("Reports progress for each selected package when deleting specific packages")
    func reportsProgressForEachSelectedPackageWhenDeletingSpecificPackages() throws {
        let package1 = makePurgeFolder(name: "Package1")
        let package2 = makePurgeFolder(name: "Package2")
        let package3 = makePurgeFolder(name: "Package3")
        let packages = [package1, package2, package3]
        let selectedIndices = [0, 2]
        let (sut, _, progressHandler) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([2]),
                multiSelectionType: .ordered([selectedIndices])
            ),
            foldersToLoad: packages
        )

        try sut.deletePackageCache(deleteAll: false)

        #expect(progressHandler.deletedFolders.count == 2)
        guard progressHandler.deletedFolders.count >= 2 else { return }
        #expect(progressHandler.deletedFolders[0].name == package1.name)
        #expect(progressHandler.deletedFolders[1].name == package3.name)
    }

    @Test("Reports no progress when no packages selected")
    func reportsNoProgressWhenNoPackagesSelected() throws {
        let packages = [
            makePurgeFolder(name: "Package1"),
            makePurgeFolder(name: "Package2")
        ]
        let (sut, _, progressHandler) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([2]),
                multiSelectionType: .ordered([[]])
            ),
            foldersToLoad: packages
        )

        try sut.deletePackageCache(deleteAll: false)

        #expect(progressHandler.deletedFolders.isEmpty)
    }

    @Test("Reports progress in correct order for multiple packages")
    func reportsProgressInCorrectOrderForMultiplePackages() throws {
        let package1 = makePurgeFolder(name: "Alpha")
        let package2 = makePurgeFolder(name: "Beta")
        let package3 = makePurgeFolder(name: "Gamma")
        let package4 = makePurgeFolder(name: "Delta")
        let packages = [package1, package2, package3, package4]
        let (sut, _, progressHandler) = makeSUT(
            permissionResult: .init(type: .ordered([true])),
            foldersToLoad: packages
        )

        try sut.deletePackageCache(deleteAll: true)

        #expect(progressHandler.deletedFolders.count == 4)
        for (index, package) in packages.enumerated() {
            #expect(progressHandler.deletedFolders[index].name == package.name)
        }
    }
}


// MARK: - SUT
private extension PackageCacheControllerTests {
    func makeSUT(
        inputResult: MockInputResult = .init(),
        permissionResult: MockPermissionResult = .init(),
        selectionResult: MockSelectionResult = .init(),
        throwError: Bool = false,
        foldersToLoad: [PurgeFolder] = []
    ) -> (sut: PackageCacheController, service: MockPurgeService, progressHandler: MockProgressHandler) {
        let picker = MockSwiftPicker(inputResult: inputResult, permissionResult: permissionResult, selectionResult: selectionResult)
        let service = MockPurgeService(throwError: throwError, foldersToLoad: foldersToLoad)
        let progressHandler = MockProgressHandler()
        let sut = PackageCacheController(picker: picker, service: service, progressHandler: progressHandler)

        return (sut, service, progressHandler)
    }
}
