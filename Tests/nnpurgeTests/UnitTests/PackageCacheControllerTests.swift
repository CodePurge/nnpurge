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
        #expect(!service.didFindDependencies)
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


// MARK: - Clean Project Dependencies Tests
extension PackageCacheControllerTests {
    @Test("Finds dependencies and deletes matching cached packages")
    func findsDependenciesAndDeletesMatchingCachedPackages() throws {
        let dependency1 = "files"
        let dependency2 = "swiftpicker"
        let package1 = makePurgeFolder(name: "Files-abc123")
        let package2 = makePurgeFolder(name: "SwiftPicker-def456")
        let package3 = makePurgeFolder(name: "OtherPackage-xyz789")
        let (sut, service, _) = makeSUT(
            permissionResult: .init(type: .ordered([true])),
            foldersToLoad: [package1, package2, package3],
            dependenciesToLoad: [dependency1, dependency2]
        )

        try sut.cleanProjectDependencies(projectPath: nil)

        #expect(service.deletedFolders.count == 2)
        #expect(service.deletedFolders.contains(where: { $0.name == package1.name }))
        #expect(service.deletedFolders.contains(where: { $0.name == package2.name }))
    }

    @Test("Throws error when user denies permission to delete")
    func throwsErrorWhenUserDeniesPermissionToDelete() throws {
        let package = makePurgeFolder(name: "Files-abc123")
        let (sut, _, _) = makeSUT(
            permissionResult: .init(type: .ordered([false])),
            foldersToLoad: [package],
            dependenciesToLoad: ["files"]
        )

        #expect(throws: SwiftPickerError.selectionCancelled) {
            try sut.cleanProjectDependencies(projectPath: nil)
        }
    }

    @Test("Does not delete packages when no matches found")
    func doesNotDeletePackagesWhenNoMatchesFound() throws {
        let package1 = makePurgeFolder(name: "SomeOtherPackage-abc123")
        let package2 = makePurgeFolder(name: "DifferentPackage-def456")
        let (sut, service, _) = makeSUT(
            foldersToLoad: [package1, package2],
            dependenciesToLoad: ["nonexistent"]
        )

        try sut.cleanProjectDependencies(projectPath: nil)

        #expect(service.deletedFolders.isEmpty)
    }

    @Test("Uses current directory when path is nil")
    func usesCurrentDirectoryWhenPathIsNil() throws {
        let (sut, service, _) = makeSUT(
            foldersToLoad: []
        )

        try? sut.cleanProjectDependencies(projectPath: nil)

        #expect(service.searchedPath == nil)
    }

    @Test("Uses specified path when provided")
    func usesSpecifiedPathWhenProvided() throws {
        let testPath = "/test/path"
        let (sut, service, _) = makeSUT(
            foldersToLoad: []
        )

        try? sut.cleanProjectDependencies(projectPath: testPath)

        #expect(service.searchedPath == testPath)
    }

    @Test("Propagates error from dependency finder")
    func propagatesErrorFromDependencyFinder() throws {
        let (sut, _, _) = makeSUT(
            throwDependencyError: true
        )

        #expect(throws: NSError.self) {
            try sut.cleanProjectDependencies(projectPath: nil)
        }
    }

    @Test("Propagates error from service when deleting")
    func propagatesErrorFromServiceWhenDeleting() throws {
        let package = makePurgeFolder(name: "Files-abc123")
        let (sut, _, _) = makeSUT(
            permissionResult: .init(type: .ordered([true])),
            throwError: true,
            foldersToLoad: [package],
            dependenciesToLoad: ["files"]
        )

        #expect(throws: NSError.self) {
            try sut.cleanProjectDependencies(projectPath: nil)
        }
    }

    @Test("Reports progress for each deleted package")
    func reportsProgressForEachDeletedPackage() throws {
        let dependency1 = "files"
        let dependency2 = "swiftpicker"
        let package1 = makePurgeFolder(name: "Files-abc123")
        let package2 = makePurgeFolder(name: "SwiftPicker-def456")
        let (sut, _, progressHandler) = makeSUT(
            permissionResult: .init(type: .ordered([true])),
            foldersToLoad: [package1, package2],
            dependenciesToLoad: [dependency1, dependency2]
        )

        try sut.cleanProjectDependencies(projectPath: nil)

        #expect(progressHandler.deletedFolders.count == 2)
        #expect(progressHandler.deletedFolders.contains(where: { $0.name == package1.name }))
        #expect(progressHandler.deletedFolders.contains(where: { $0.name == package2.name }))
    }

    @Test("Matches packages case insensitively")
    func matchesPackagesCaseInsensitively() throws {
        let dependency = "swiftpicker"
        let package1 = makePurgeFolder(name: "SwiftPicker-abc123")
        let package2 = makePurgeFolder(name: "SWIFTPICKER-def456")
        let (sut, service, _) = makeSUT(
            permissionResult: .init(type: .ordered([true])),
            foldersToLoad: [package1, package2],
            dependenciesToLoad: [dependency]
        )

        try sut.cleanProjectDependencies(projectPath: nil)

        #expect(service.deletedFolders.count == 2)
    }

    @Test("Only deletes packages matching dependency identities")
    func onlyDeletesPackagesMatchingDependencyIdentities() throws {
        let package1 = makePurgeFolder(name: "Files-abc123")
        let package2 = makePurgeFolder(name: "SwiftPicker-def456")
        let package3 = makePurgeFolder(name: "firebase-ios-sdk-xyz789")
        let (sut, service, _) = makeSUT(
            permissionResult: .init(type: .ordered([true])),
            foldersToLoad: [package1, package2, package3],
            dependenciesToLoad: ["files"]
        )

        try sut.cleanProjectDependencies(projectPath: nil)

        #expect(service.deletedFolders.count == 1)
        #expect(service.deletedFolders.first?.name == package1.name)
    }
}


// MARK: - SUT
private extension PackageCacheControllerTests {
    func makeSUT(
        inputResult: MockInputResult = .init(),
        permissionResult: MockPermissionResult = .init(),
        selectionResult: MockSelectionResult = .init(),
        throwError: Bool = false,
        foldersToLoad: [PurgeFolder] = [],
        dependenciesToLoad: [String] = [],
        throwDependencyError: Bool = false
    ) -> (sut: PackageCacheController, service: MockPurgeService, progressHandler: MockProgressHandler) {
        let picker = MockSwiftPicker(inputResult: inputResult, permissionResult: permissionResult, selectionResult: selectionResult)
        let service = MockPurgeService(throwError: throwError, throwDependencyError: throwDependencyError, foldersToLoad: foldersToLoad, dependenciesToLoad: dependenciesToLoad)
        let progressHandler = MockProgressHandler()
        let sut = PackageCacheController(picker: picker, service: service, progressHandler: progressHandler)

        return (sut, service, progressHandler)
    }

    func makePurgeFolder(name: String = "TestFolder") -> PurgeFolder {
        PurgeFolder(
            url: URL(fileURLWithPath: "/test/\(name)"),
            name: name,
            path: "/test/\(name)",
            size: 1024
        )
    }
}
