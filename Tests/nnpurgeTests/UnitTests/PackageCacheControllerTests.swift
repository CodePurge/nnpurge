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

        #expect(service.deletedPackageCacheFolders.isEmpty)
        #expect(!service.didFindDependencies)
        #expect(!progressHandler.didComplete)
        #expect(progressHandler.completedMessage == nil)
        #expect(progressHandler.progressUpdates.isEmpty)
    }
}


// MARK: - Delete All Flag Tests
extension PackageCacheControllerTests {
    @Test("Deletes all packages when flag true and permission granted")
    func deletesAllPackagesWhenFlagTrueAndPermissionGranted() throws {
        let packages = [
            makePackageCacheFolder(name: "Package1"),
            makePackageCacheFolder(name: "Package2")
        ]
        let (sut, service, _) = makeSUT(
            permissionResult: .init(grantByDefault: true, type: .ordered([true])),
            packageCacheFoldersToLoad: packages
        )

        try sut.deletePackageCache(deleteAll: true)

        #expect(service.deletedPackageCacheFolders.count == packages.count)
    }

    @Test("Throws error when delete all flag true but permission denied")
    func throwsErrorWhenDeleteAllFlagTrueButPermissionDenied() throws {
        let (sut, _, _) = makeSUT(
            permissionResult: .init(grantByDefault: false, type: .ordered([false]))
        )

        #expect(throws: SwiftPickerError.selectionCancelled) {
            try sut.deletePackageCache(deleteAll: true)
        }
    }

    @Test("Requests permission with correct prompt when deleting all")
    func requestsPermissionWithCorrectPromptWhenDeletingAll() throws {
        let expectedPrompt = "Are you sure you want to delete all derived data?"
        let (sut, _, _) = makeSUT(
            permissionResult: .init(
                grantByDefault: true,
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
            permissionResult: .init(grantByDefault: true, type: .ordered([true])),
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
        let packages = [
            makePackageCacheFolder(name: "Package1"),
            makePackageCacheFolder(name: "Package2")
        ]
        let (sut, service, _) = makeSUT(
            permissionResult: .init(grantByDefault: true, type: .ordered([true])),
            selectionResult: .init(
                singleSelectionType: .ordered([deleteAllIndex])
            ),
            packageCacheFoldersToLoad: packages
        )

        try sut.deletePackageCache(deleteAll: false)

        #expect(service.deletedPackageCacheFolders.count == packages.count)
    }

    @Test("Shows package selection when user selects select folders option")
    func showsPackageSelectionWhenUserSelectsSelectFoldersOption() throws {
        let selectFoldersIndex = 2
        let packages = [
            makePackageCacheFolder(name: "Package1"),
            makePackageCacheFolder(name: "Package2")
        ]
        let (sut, service, _) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([selectFoldersIndex]),
                multiSelectionType: .ordered([[0]])
            ),
            packageCacheFoldersToLoad: packages
        )

        try sut.deletePackageCache(deleteAll: false)

        #expect(service.deletedPackageCacheFolders.count == 1)
        #expect(service.deletedPackageCacheFolders.first?.name == packages[0].name)
    }
}


// MARK: - Delete Stale Packages Tests
extension PackageCacheControllerTests {
    @Test("Deletes stale packages when user selects delete stale option")
    func deleteStalePackagesWhenUserSelectsDeleteStaleOption() throws {
        let deleteStaleIndex = 1
        let oldDate = Calendar.current.date(byAdding: .day, value: -40, to: Date())
        let recentDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())
        let stalePackage = makePackageCacheFolder(name: "OldPackage", modificationDate: oldDate)
        let recentPackage = makePackageCacheFolder(name: "RecentPackage", modificationDate: recentDate)
        let (sut, service, _) = makeSUT(
            permissionResult: .init(grantByDefault: true, type: .ordered([true])),
            selectionResult: .init(
                singleSelectionType: .ordered([deleteStaleIndex])
            ),
            packageCacheFoldersToLoad: [stalePackage, recentPackage]
        )

        try sut.deletePackageCache(deleteAll: false)

        #expect(service.deletedPackageCacheFolders.count == 1)
        #expect(service.deletedPackageCacheFolders.first?.name == stalePackage.name)
    }

    @Test("Requests permission with correct count when deleting stale packages")
    func requestsPermissionWithCorrectCountWhenDeletingStalePackages() throws {
        let deleteStaleIndex = 1
        let oldDate = Calendar.current.date(byAdding: .day, value: -40, to: Date())
        let stalePackage1 = makePackageCacheFolder(name: "OldPackage1", modificationDate: oldDate)
        let stalePackage2 = makePackageCacheFolder(name: "OldPackage2", modificationDate: oldDate)
        let expectedPrompt = "Are you sure you want to delete 2 stale packages (not modified in 30+ days)?"
        let (sut, _, _) = makeSUT(
            permissionResult: .init(
                grantByDefault: true,
                type: .dictionary([expectedPrompt: true])
            ),
            selectionResult: .init(
                singleSelectionType: .ordered([deleteStaleIndex])
            ),
            packageCacheFoldersToLoad: [stalePackage1, stalePackage2]
        )

        try sut.deletePackageCache(deleteAll: false)
    }

    @Test("Throws error when user denies permission to delete stale packages")
    func throwsErrorWhenUserDeniesPermissionToDeleteStalePackages() throws {
        let deleteStaleIndex = 1
        let oldDate = Calendar.current.date(byAdding: .day, value: -40, to: Date())
        let stalePackage = makePackageCacheFolder(name: "OldPackage", modificationDate: oldDate)
        let (sut, _, _) = makeSUT(
            permissionResult: .init(grantByDefault: false, type: .ordered([false])),
            selectionResult: .init(
                singleSelectionType: .ordered([deleteStaleIndex])
            ),
            packageCacheFoldersToLoad: [stalePackage]
        )

        #expect(throws: SwiftPickerError.selectionCancelled) {
            try sut.deletePackageCache(deleteAll: false)
        }
    }
}


// MARK: - Select Packages Flow Tests
extension PackageCacheControllerTests {
    @Test("Deletes selected packages when user makes selection")
    func deletesSelectedPackagesWhenUserMakesSelection() throws {
        let package1 = makePackageCacheFolder(name: "Package1")
        let package2 = makePackageCacheFolder(name: "Package2")
        let package3 = makePackageCacheFolder(name: "Package3")
        let packages = [package1, package2, package3]
        let selectedIndices = [0, 2]
        let (sut, service, _) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([2]),
                multiSelectionType: .ordered([selectedIndices])
            ),
            packageCacheFoldersToLoad: packages
        )

        try sut.deletePackageCache(deleteAll: false)

        #expect(service.deletedPackageCacheFolders.count == 2)
        #expect(service.deletedPackageCacheFolders.contains(where: { $0.name == package1.name }))
        #expect(service.deletedPackageCacheFolders.contains(where: { $0.name == package3.name }))
    }

    @Test("Deletes no packages when user selects none")
    func deletesNoPackagesWhenUserSelectsNone() throws {
        let packages = [
            makePackageCacheFolder(name: "Package1"),
            makePackageCacheFolder(name: "Package2")
        ]
        let (sut, service, _) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([2]),
                multiSelectionType: .ordered([[]])
            ),
            packageCacheFoldersToLoad: packages
        )

        try sut.deletePackageCache(deleteAll: false)

        #expect(service.deletedPackageCacheFolders.isEmpty)
    }

    @Test("Shows multi selection with correct prompt and packages")
    func showsMultiSelectionWithCorrectPromptAndPackages() throws {
        let expectedPrompt = "Select the folders to delete."
        let packages = [
            makePackageCacheFolder(name: "Package1"),
            makePackageCacheFolder(name: "Package2")
        ]
        let (sut, _, _) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([2]),
                multiSelectionType: .dictionary([expectedPrompt: [0]])
            ),
            packageCacheFoldersToLoad: packages
        )

        try sut.deletePackageCache(deleteAll: false)
    }
}


// MARK: - Error Handling Tests
extension PackageCacheControllerTests {
    @Test("Propagates delete all error from service")
    func propagatesDeleteAllErrorFromService() throws {
        let (sut, _, _) = makeSUT(
            permissionResult: .init(grantByDefault: true, type: .ordered([true])),
            throwError: true
        )

        #expect(throws: NSError.self) {
            try sut.deletePackageCache(deleteAll: true)
        }
    }

    @Test("Propagates delete folders error from service")
    func propagatesDeleteFoldersErrorFromService() throws {
        let packages = [makePackageCacheFolder(name: "Package1")]
        let (sut, _, _) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([2]),
                multiSelectionType: .ordered([[0]])
            ),
            throwError: true,
            packageCacheFoldersToLoad: packages
        )

        #expect(throws: NSError.self) {
            try sut.deletePackageCache(deleteAll: false)
        }
    }
}


// MARK: - Open Folder Tests
extension PackageCacheControllerTests {
    @Test("Opens package cache folder prints message")
    func opensPackageCacheFolderPrintsMessage() throws {
        let (sut, _, _) = makeSUT()

        try sut.openPackageCacheFolder()
    }
}


// MARK: - Progress Handler Tests
extension PackageCacheControllerTests {
    @Test("Reports progress for each package when deleting all", .disabled())
    func reportsProgressForEachPackageWhenDeletingAll() throws {
        let package1 = makePackageCacheFolder(name: "Package1")
        let package2 = makePackageCacheFolder(name: "Package2")
        let package3 = makePackageCacheFolder(name: "Package3")
        let packages = [package1, package2, package3]
        let (sut, _, progressHandler) = makeSUT(
            permissionResult: .init(grantByDefault: true, type: .ordered([true])),
            packageCacheFoldersToLoad: packages
        )

        try sut.deletePackageCache(deleteAll: true)

        #expect(progressHandler.progressUpdates.count == packages.count)
        guard progressHandler.progressUpdates.count >= 3 else { return }
        #expect(progressHandler.progressUpdates[0].message.contains(package1.name))
        #expect(progressHandler.progressUpdates[1].message.contains(package2.name))
        #expect(progressHandler.progressUpdates[2].message.contains(package3.name))
    }

    @Test("Reports progress for each selected package when deleting specific packages", .disabled())
    func reportsProgressForEachSelectedPackageWhenDeletingSpecificPackages() throws {
        let package1 = makePackageCacheFolder(name: "Package1")
        let package2 = makePackageCacheFolder(name: "Package2")
        let package3 = makePackageCacheFolder(name: "Package3")
        let packages = [package1, package2, package3]
        let selectedIndices = [0, 2]
        let (sut, _, progressHandler) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([2]),
                multiSelectionType: .ordered([selectedIndices])
            ),
            packageCacheFoldersToLoad: packages
        )

        try sut.deletePackageCache(deleteAll: false)

        #expect(progressHandler.progressUpdates.count == 2)
        guard progressHandler.progressUpdates.count >= 2 else { return }
        #expect(progressHandler.progressUpdates[0].message.contains(package1.name))
        #expect(progressHandler.progressUpdates[1].message.contains(package3.name))
    }

    @Test("Reports no progress when no packages selected", .disabled())
    func reportsNoProgressWhenNoPackagesSelected() throws {
        let packages = [
            makePackageCacheFolder(name: "Package1"),
            makePackageCacheFolder(name: "Package2")
        ]
        let (sut, _, progressHandler) = makeSUT(
            selectionResult: .init(
                singleSelectionType: .ordered([2]),
                multiSelectionType: .ordered([[]])
            ),
            packageCacheFoldersToLoad: packages
        )

        try sut.deletePackageCache(deleteAll: false)

        #expect(progressHandler.progressUpdates.isEmpty)
    }

    @Test("Reports progress in correct order for multiple packages", .disabled())
    func reportsProgressInCorrectOrderForMultiplePackages() throws {
        let package1 = makePackageCacheFolder(name: "Alpha")
        let package2 = makePackageCacheFolder(name: "Beta")
        let package3 = makePackageCacheFolder(name: "Gamma")
        let package4 = makePackageCacheFolder(name: "Delta")
        let packages = [package1, package2, package3, package4]
        let (sut, _, progressHandler) = makeSUT(
            permissionResult: .init(grantByDefault: true, type: .ordered([true])),
            packageCacheFoldersToLoad: packages
        )

        try sut.deletePackageCache(deleteAll: true)

        #expect(progressHandler.progressUpdates.count == 4)
        for (index, package) in packages.enumerated() {
            #expect(progressHandler.progressUpdates[index].message.contains(package.name))
        }
    }
}


// MARK: - Clean Project Dependencies Tests
extension PackageCacheControllerTests {
    @Test("Finds dependencies and deletes matching cached packages")
    func findsDependenciesAndDeletesMatchingCachedPackages() throws {
        let dependency1 = "files"
        let dependency2 = "swiftpicker"
        let package1 = makePackageCacheFolder(name: "Files-abc123")
        let package2 = makePackageCacheFolder(name: "SwiftPicker-def456")
        let package3 = makePackageCacheFolder(name: "OtherPackage-xyz789")
        let (sut, service, _) = makeSUT(
            permissionResult: .init(grantByDefault: true, type: .ordered([true])),
            packageCacheFoldersToLoad: [package1, package2, package3],
            dependenciesToLoad: [dependency1, dependency2]
        )

        try sut.cleanProjectDependencies(projectPath: nil)

        #expect(service.deletedPackageCacheFolders.count == 2)
        #expect(service.deletedPackageCacheFolders.contains(where: { $0.name == package1.name }))
        #expect(service.deletedPackageCacheFolders.contains(where: { $0.name == package2.name }))
    }

    @Test("Throws error when user denies permission to delete")
    func throwsErrorWhenUserDeniesPermissionToDelete() throws {
        let package = makePackageCacheFolder(name: "Files-abc123")
        let (sut, _, _) = makeSUT(
            permissionResult: .init(grantByDefault: false, type: .ordered([false])),
            packageCacheFoldersToLoad: [package],
            dependenciesToLoad: ["files"]
        )

        #expect(throws: SwiftPickerError.selectionCancelled) {
            try sut.cleanProjectDependencies(projectPath: nil)
        }
    }

    @Test("Does not delete packages when no matches found")
    func doesNotDeletePackagesWhenNoMatchesFound() throws {
        let package1 = makePackageCacheFolder(name: "SomeOtherPackage-abc123")
        let package2 = makePackageCacheFolder(name: "DifferentPackage-def456")
        let (sut, service, _) = makeSUT(
            packageCacheFoldersToLoad: [package1, package2],
            dependenciesToLoad: ["nonexistent"]
        )

        try sut.cleanProjectDependencies(projectPath: nil)

        #expect(service.deletedPackageCacheFolders.isEmpty)
    }

    @Test("Uses current directory when path is nil")
    func usesCurrentDirectoryWhenPathIsNil() throws {
        let (sut, service, _) = makeSUT(
            packageCacheFoldersToLoad: []
        )

        try? sut.cleanProjectDependencies(projectPath: nil)

        #expect(service.searchedPath == nil)
    }

    @Test("Uses specified path when provided")
    func usesSpecifiedPathWhenProvided() throws {
        let testPath = "/test/path"
        let (sut, service, _) = makeSUT(
            packageCacheFoldersToLoad: []
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
        let package = makePackageCacheFolder(name: "Files-abc123")
        let (sut, _, _) = makeSUT(
            permissionResult: .init(grantByDefault: true, type: .ordered([true])),
            throwError: true,
            packageCacheFoldersToLoad: [package],
            dependenciesToLoad: ["files"]
        )

        #expect(throws: NSError.self) {
            try sut.cleanProjectDependencies(projectPath: nil)
        }
    }

    @Test("Reports progress for each deleted package", .disabled())
    func reportsProgressForEachDeletedPackage() throws {
        let dependency1 = "files"
        let dependency2 = "swiftpicker"
        let package1 = makePackageCacheFolder(name: "Files-abc123")
        let package2 = makePackageCacheFolder(name: "SwiftPicker-def456")
        let (sut, _, progressHandler) = makeSUT(
            permissionResult: .init(grantByDefault: true, type: .ordered([true])),
            packageCacheFoldersToLoad: [package1, package2],
            dependenciesToLoad: [dependency1, dependency2]
        )

        try sut.cleanProjectDependencies(projectPath: nil)

        #expect(progressHandler.progressUpdates.count == 2)
        #expect(progressHandler.progressUpdates[0].message.contains(package1.name))
        #expect(progressHandler.progressUpdates[1].message.contains(package2.name))
    }

    @Test("Matches packages case insensitively")
    func matchesPackagesCaseInsensitively() throws {
        let dependency = "swiftpicker"
        let package1 = makePackageCacheFolder(name: "SwiftPicker-abc123")
        let package2 = makePackageCacheFolder(name: "SWIFTPICKER-def456")
        let (sut, service, _) = makeSUT(
            permissionResult: .init(grantByDefault: true, type: .ordered([true])),
            packageCacheFoldersToLoad: [package1, package2],
            dependenciesToLoad: [dependency]
        )

        try sut.cleanProjectDependencies(projectPath: nil)

        #expect(service.deletedPackageCacheFolders.count == 2)
    }

    @Test("Only deletes packages matching dependency identities")
    func onlyDeletesPackagesMatchingDependencyIdentities() throws {
        let package1 = makePackageCacheFolder(name: "Files-abc123")
        let package2 = makePackageCacheFolder(name: "SwiftPicker-def456")
        let package3 = makePackageCacheFolder(name: "firebase-ios-sdk-xyz789")
        let (sut, service, _) = makeSUT(
            permissionResult: .init(grantByDefault: true, type: .ordered([true])),
            packageCacheFoldersToLoad: [package1, package2, package3],
            dependenciesToLoad: ["files"]
        )

        try sut.cleanProjectDependencies(projectPath: nil)

        #expect(service.deletedPackageCacheFolders.count == 1)
        #expect(service.deletedPackageCacheFolders.first?.name == package1.name)
    }
}


// MARK: - Xcode Running User Prompt Tests
extension PackageCacheControllerTests {
    @Test("Shows Xcode running prompt with three options")
    func showsXcodeRunningPromptWithThreeOptions() throws {
        let packages = [makePackageCacheFolder(name: "Package1")]
        let expectedPrompt = "Xcode is currently running. What would you like to do?"
        let (sut, _, _) = makeSUT(
            permissionResult: .init(grantByDefault: true, type: .ordered([true])),
            selectionResult: .init(
                singleSelectionType: .dictionary([expectedPrompt: 2]) // Cancel option
            ),
            packageCacheFoldersToLoad: packages,
            throwXcodeRunning: true
        )

        try? sut.deletePackageCache(deleteAll: true)
    }

    @Test("Proceeds with force deletion when user selects proceed anyway option")
    func proceedsWithForceDeletionWhenUserSelectsProceedAnywayOption() throws {
        let packages = [
            makePackageCacheFolder(name: "Package1"),
            makePackageCacheFolder(name: "Package2")
        ]
        let proceedAnywayIndex = 0
        let (sut, service, _) = makeSUT(
            permissionResult: .init(grantByDefault: true, type: .ordered([true])),
            selectionResult: .init(
                singleSelectionType: .ordered([proceedAnywayIndex])
            ),
            packageCacheFoldersToLoad: packages,
            throwXcodeRunning: true
        )

        try sut.deletePackageCache(deleteAll: true)

        #expect(service.deletedPackageCacheFolders.count == 2)
        #expect(service.deletedPackageCacheFolders.contains(where: { $0.name == packages[0].name }))
        #expect(service.deletedPackageCacheFolders.contains(where: { $0.name == packages[1].name }))
    }

    @Test("Waits for user to close Xcode and proceeds when confirmed")
    func waitsForUserToCloseXcodeAndProceedsWhenConfirmed() throws {
        let packages = [makePackageCacheFolder(name: "Package1")]
        let waitUntilClosedIndex = 1
        let (sut, service, _) = makeSUT(
            permissionResult: .init(grantByDefault: true, type: .ordered([true])),
            selectionResult: .init(
                singleSelectionType: .ordered([waitUntilClosedIndex])
            ),
            packageCacheFoldersToLoad: packages,
            throwXcodeRunning: true
        )

        try sut.deletePackageCache(deleteAll: true)

        #expect(service.deletedPackageCacheFolders.count == 1)
    }

    @Test("Cancels operation when user selects cancel option")
    func cancelsOperationWhenUserSelectsCancelOption() throws {
        let packages = [makePackageCacheFolder(name: "Package1")]
        let cancelIndex = 2
        let (sut, service, _) = makeSUT(
            permissionResult: .init(grantByDefault: true, type: .ordered([true])),
            selectionResult: .init(
                singleSelectionType: .ordered([cancelIndex])
            ),
            packageCacheFoldersToLoad: packages,
            throwXcodeRunning: true
        )

        try sut.deletePackageCache(deleteAll: true)

        #expect(service.deletedPackageCacheFolders.isEmpty)
    }

    @Test("Throws error when user denies Xcode closure confirmation")
    func throwsErrorWhenUserDeniesXcodeClosureConfirmation() throws {
        let packages = [makePackageCacheFolder(name: "Package1")]
        let waitUntilClosedIndex = 1
        let (sut, _, _) = makeSUT(
            permissionResult: .init(grantByDefault: false, type: .ordered([false])),
            selectionResult: .init(
                singleSelectionType: .ordered([waitUntilClosedIndex])
            ),
            packageCacheFoldersToLoad: packages,
            throwXcodeRunning: true
        )

        #expect(throws: (any Error).self) {
            try sut.deletePackageCache(deleteAll: true)
        }
    }
}


// MARK: - Clean Dependencies Xcode Prompt Tests
extension PackageCacheControllerTests {
    @Test("Proceeds with force deletion when cleaning dependencies and user selects proceed anyway")
    func proceedsWithForceDeletionWhenCleaningDependenciesAndUserSelectsProceedAnyway() throws {
        let package = makePackageCacheFolder(name: "Files-abc123")
        let proceedAnywayIndex = 0
        let (sut, service, _) = makeSUT(
            permissionResult: .init(grantByDefault: true, type: .ordered([true])),
            selectionResult: .init(
                singleSelectionType: .ordered([proceedAnywayIndex])
            ),
            packageCacheFoldersToLoad: [package],
            dependenciesToLoad: ["files"],
            throwXcodeRunning: true
        )

        try sut.cleanProjectDependencies(projectPath: nil as String?)

        #expect(service.deletedPackageCacheFolders.count == 1)
        #expect(service.deletedPackageCacheFolders.first?.name == package.name)
    }

    @Test("Waits for user to close Xcode when cleaning dependencies")
    func waitsForUserToCloseXcodeWhenCleaningDependencies() throws {
        let package = makePackageCacheFolder(name: "SwiftPicker-def456")
        let waitUntilClosedIndex = 1
        let (sut, service, _) = makeSUT(
            permissionResult: .init(grantByDefault: true, type: .ordered([true])),
            selectionResult: .init(
                singleSelectionType: .ordered([waitUntilClosedIndex])
            ),
            packageCacheFoldersToLoad: [package],
            dependenciesToLoad: ["swiftpicker"],
            throwXcodeRunning: true
        )

        try sut.cleanProjectDependencies(projectPath: nil as String?)

        #expect(service.deletedPackageCacheFolders.count == 1)
    }

    @Test("Cancels clean dependencies when user selects cancel")
    func cancelsCleanDependenciesWhenUserSelectsCancel() throws {
        let package = makePackageCacheFolder(name: "Files-abc123")
        let cancelIndex = 2
        let (sut, service, _) = makeSUT(
            permissionResult: .init(grantByDefault: true, type: .ordered([true])),
            selectionResult: .init(
                singleSelectionType: .ordered([cancelIndex])
            ),
            packageCacheFoldersToLoad: [package],
            dependenciesToLoad: ["files"],
            throwXcodeRunning: true
        )

        try sut.cleanProjectDependencies(projectPath: nil as String?)

        #expect(service.deletedPackageCacheFolders.isEmpty)
    }
}


// MARK: - SUT
private extension PackageCacheControllerTests {
    func makeSUT(
        inputResult: MockInputResult = .init(),
        permissionResult: MockPermissionResult = .init(grantByDefault: true, type: .ordered([])),
        selectionResult: MockSelectionResult = .init(),
        throwError: Bool = false,
        packageCacheFoldersToLoad: [PackageCacheFolder] = [],
        dependenciesToLoad: [String] = [],
        throwDependencyError: Bool = false,
        throwXcodeRunning: Bool = false,
        closeXcodeSucceeds: Bool = true
    ) -> (sut: PackageCacheController, service: MockPurgeService, progressHandler: MockPurgeProgressHandler) {
        let progressHandler = MockPurgeProgressHandler()
        let picker = MockSwiftPicker(
            inputResult: inputResult,
            permissionResult: permissionResult,
            selectionResult: selectionResult
        )
        let service = MockPurgeService(
            throwError: throwError,
            throwDependencyError: throwDependencyError,
            packageCacheFoldersToLoad: packageCacheFoldersToLoad,
            dependenciesToLoad: dependenciesToLoad,
            throwXcodeRunning: throwXcodeRunning,
            closeXcodeSucceeds: closeXcodeSucceeds
        )
        let sut = PackageCacheController(
            picker: picker,
            service: service,
            progressHandler: progressHandler
        )

        return (sut, service, progressHandler)
    }

    func makePackageCacheFolder(name: String, modificationDate: Date? = nil, creationDate: Date? = nil) -> PackageCacheFolder {
        let url = URL(fileURLWithPath: "/path/to/cache/\(name)")

        return .init(
            url: url,
            name: name,
            path: url.path,
            creationDate: creationDate ?? Date(),
            modificationDate: modificationDate ?? Date(),
            branchId: "abc123",
            lastFetchedDate: "2024-01-01"
        )
    }
}
